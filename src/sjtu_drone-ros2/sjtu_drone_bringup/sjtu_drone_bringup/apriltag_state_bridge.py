#!/usr/bin/env python3

import math

import rclpy
from rclpy.node import Node

from apriltag_msgs.msg import AprilTagDetectionArray
from std_msgs.msg import Float32MultiArray
from std_msgs.msg import Int8
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import cv2
import numpy as np


class AprilTagStateBridge(Node):
    def __init__(self):
        super().__init__('apriltag_state_bridge')

        self.declare_parameter('input_topic', '/drone/bottom/tags')
        self.declare_parameter('output_topic', '/landing_tag_state')
        self.declare_parameter('output_image_topic', '/landing_tag_image_annotated')
        self.declare_parameter('image_topic', '/drone/bottom/image_raw')
        self.declare_parameter('target_id', 0)
        self.declare_parameter('use_target_id', True)
        self.declare_parameter('publish_annotated_image', True)
        self.declare_parameter('state_topic', '/drone/state')
        self.declare_parameter('monitor_log_period_sec', 2.0)

        input_topic = self.get_parameter('input_topic').get_parameter_value().string_value
        output_topic = self.get_parameter('output_topic').get_parameter_value().string_value
        output_image_topic = self.get_parameter('output_image_topic').get_parameter_value().string_value
        image_topic = self.get_parameter('image_topic').get_parameter_value().string_value
        state_topic = self.get_parameter('state_topic').get_parameter_value().string_value
        self.target_id = int(self.get_parameter('target_id').value)
        self.use_target_id = bool(self.get_parameter('use_target_id').value)
        self.publish_annotated_image = bool(self.get_parameter('publish_annotated_image').value)
        monitor_log_period_sec = float(self.get_parameter('monitor_log_period_sec').value)
        monitor_log_period_sec = max(0.5, monitor_log_period_sec)

        self.ns_hint = self._infer_namespace(output_topic)
        self.last_state = -1
        self.tag_msg_count = 0
        self.tag_detect_count = 0
        self.state_msg_count = 0
        self.state_msg_count_since_log = 0
        self.tag_msg_count_since_log = 0
        self.tag_detect_count_since_log = 0
        self.last_log_time_ns = self.get_clock().now().nanoseconds

        self.pub = self.create_publisher(Float32MultiArray, output_topic, 10)
        if self.publish_annotated_image:
            self.image_pub = self.create_publisher(Image, output_image_topic, 10)
        
        self.sub = self.create_subscription(AprilTagDetectionArray, input_topic, self.cb, 10)
        self.state_sub = self.create_subscription(Int8, state_topic, self.state_cb, 10)
        if self.publish_annotated_image:
            self.image_sub = self.create_subscription(Image, image_topic, self.image_cb, 10)
            self.latest_image = None
            self.bridge = CvBridge()

        self.monitor_timer = self.create_timer(monitor_log_period_sec, self.monitor_cb)

        self.get_logger().info(
            f'AprilTag bridge started: {input_topic} -> {output_topic}, '
            f'use_target_id={self.use_target_id}, target_id={self.target_id}, '
            f'annotated_image={self.publish_annotated_image}'
        )

    @staticmethod
    def _infer_namespace(topic_name: str) -> str:
        t = (topic_name or '').strip()
        if not t.startswith('/'):
            t = '/' + t
        parts = [p for p in t.split('/') if p]
        if len(parts) >= 1:
            return '/' + parts[0]
        return '/drone'

    def state_cb(self, msg: Int8):
        self.last_state = int(msg.data)
        self.state_msg_count += 1
        self.state_msg_count_since_log += 1

    def monitor_cb(self):
        now_ns = self.get_clock().now().nanoseconds
        dt = max(1e-6, (now_ns - self.last_log_time_ns) / 1e9)
        tag_hz = self.tag_msg_count_since_log / dt
        state_hz = self.state_msg_count_since_log / dt
        if self.tag_msg_count_since_log > 0:
            detect_rate = self.tag_detect_count_since_log / self.tag_msg_count_since_log
        else:
            detect_rate = 0.0

        self.get_logger().info(
            f'[MULTI_MON] ns={self.ns_hint} state={self.last_state} '
            f'state_hz={state_hz:.2f} tag_detect_rate={detect_rate:.3f} tag_hz={tag_hz:.2f}'
        )

        self.tag_msg_count_since_log = 0
        self.tag_detect_count_since_log = 0
        self.state_msg_count_since_log = 0
        self.last_log_time_ns = now_ns

    def image_cb(self, msg: Image):
        """Store latest camera image"""
        if self.publish_annotated_image:
            try:
                self.latest_image = self.bridge.imgmsg_to_cv2(msg, desired_encoding='bgr8')
            except Exception as e:
                self.get_logger().warn(f'Failed to convert image: {str(e)}')

    def cb(self, msg: AprilTagDetectionArray):
        self.tag_msg_count += 1
        self.tag_msg_count_since_log += 1
        det = self._select_detection(msg)

        out = Float32MultiArray()
        # data format:
        # [detected(0/1), tag_id, center_x_px, center_y_px, area_px2, margin, num_tags]
        data = [0.0, -1.0, math.nan, math.nan, math.nan, math.nan, float(len(msg.detections))]

        if det is not None:
            self.tag_detect_count += 1
            self.tag_detect_count_since_log += 1
            center_x, center_y = self._center(det)
            area = self._area(det)
            margin = float(getattr(det, 'decision_margin', math.nan))
            tag_id = float(getattr(det, 'id', -1))
            data = [1.0, tag_id, center_x, center_y, area, margin, float(len(msg.detections))]

        out.data = data
        self.pub.publish(out)

        # Publish annotated image if available
        if self.publish_annotated_image and self.latest_image is not None:
            annotated = self._create_annotated_image(self.latest_image, msg)
            image_msg = self.bridge.cv2_to_imgmsg(annotated, encoding='bgr8')
            image_msg.header = msg.header
            self.image_pub.publish(image_msg)

    def _create_annotated_image(self, image, msg: AprilTagDetectionArray):
        """Draw AprilTag detections on image"""
        annotated = image.copy()
        
        for det in msg.detections:
            corners = getattr(det, 'corners', [])
            tag_id = int(getattr(det, 'id', -1))
            
            if corners:
                # Draw corner points and lines
                pts = np.array([[float(c.x), float(c.y)] for c in corners], dtype=np.int32)
                pts = pts.reshape((-1, 1, 2))
                
                # Draw polygon
                cv2.polylines(annotated, [pts], True, (0, 255, 0), 2)
                
                # Draw corner circles
                for pt in pts:
                    cv2.circle(annotated, tuple(pt[0]), 4, (0, 255, 255), -1)
                
                # Draw tag ID
                if len(corners) > 0:
                    cx = int(float(corners[0].x))
                    cy = int(float(corners[0].y))
                    cv2.putText(annotated, f'ID:{tag_id}', (cx, cy-10), 
                               cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        
        return annotated

    def _select_detection(self, msg: AprilTagDetectionArray):
        if not msg.detections:
            return None

        if self.use_target_id:
            for det in msg.detections:
                if int(getattr(det, 'id', -9999)) == self.target_id:
                    return det
            return None

        best = None
        best_margin = -1e9
        for det in msg.detections:
            margin = float(getattr(det, 'decision_margin', 0.0))
            if margin > best_margin:
                best = det
                best_margin = margin
        return best

    @staticmethod
    def _center(det):
        if hasattr(det, 'centre'):
            return float(det.centre.x), float(det.centre.y)
        if hasattr(det, 'center'):
            return float(det.center.x), float(det.center.y)

        corners = getattr(det, 'corners', [])
        if not corners:
            return math.nan, math.nan
        xs = [float(c.x) for c in corners]
        ys = [float(c.y) for c in corners]
        return sum(xs) / len(xs), sum(ys) / len(ys)

    @staticmethod
    def _area(det):
        corners = getattr(det, 'corners', [])
        if len(corners) < 3:
            return math.nan

        xs = [float(c.x) for c in corners]
        ys = [float(c.y) for c in corners]
        xs.append(xs[0])
        ys.append(ys[0])

        shoelace = 0.0
        for i in range(len(corners)):
            shoelace += xs[i] * ys[i + 1] - xs[i + 1] * ys[i]
        return abs(0.5 * shoelace)


def main(args=None):
    rclpy.init(args=args)
    node = AprilTagStateBridge()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
