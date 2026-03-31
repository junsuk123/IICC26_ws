#!/usr/bin/env python3

import math

import rclpy
from rclpy.node import Node

from std_msgs.msg import Float32MultiArray
from visualization_msgs.msg import Marker
from geometry_msgs.msg import Point


class TrajectoryGuidanceMarkerBridge(Node):
    def __init__(self):
        super().__init__('trajectory_guidance_marker_bridge')

        self.declare_parameter('input_topic', '/drone/trajectory_guidance')
        self.declare_parameter('output_topic', '/drone/trajectory_guidance_marker')
        self.declare_parameter('frame_id', 'world')
        self.declare_parameter('line_width', 0.05)

        self.input_topic = self.get_parameter('input_topic').get_parameter_value().string_value
        self.output_topic = self.get_parameter('output_topic').get_parameter_value().string_value
        self.frame_id = self.get_parameter('frame_id').get_parameter_value().string_value
        self.line_width = max(0.01, float(self.get_parameter('line_width').value))

        self.pub = self.create_publisher(Marker, self.output_topic, 10)
        self.sub = self.create_subscription(Float32MultiArray, self.input_topic, self.cb, 10)

        self.get_logger().info(
            f'Trajectory marker bridge started: {self.input_topic} -> {self.output_topic} (frame={self.frame_id})'
        )

    def cb(self, msg: Float32MultiArray):
        data = list(msg.data)
        if len(data) < 7:
            return

        x = self._safe(data[1], 0.0)
        y = self._safe(data[2], 0.0)
        z = self._safe(data[3], 0.0)
        tx = self._safe(data[4], x)
        ty = self._safe(data[5], y)
        tz = self._safe(data[6], z)

        source_code = 0.0
        if len(data) > 10:
            source_code = self._safe(data[10], 0.0)

        m = Marker()
        m.header.stamp = self.get_clock().now().to_msg()
        m.header.frame_id = self.frame_id
        m.ns = 'autosim_guidance'
        m.id = 1
        m.type = Marker.LINE_STRIP
        m.action = Marker.ADD
        m.pose.orientation.w = 1.0
        m.scale.x = self.line_width

        if source_code >= 1.5:
            m.color.r = 0.95
            m.color.g = 0.70
            m.color.b = 0.12
        elif source_code >= 0.5:
            m.color.r = 0.10
            m.color.g = 0.90
            m.color.b = 0.35
        else:
            m.color.r = 0.15
            m.color.g = 0.75
            m.color.b = 0.95
        m.color.a = 1.0

        p0 = Point()
        p0.x = x
        p0.y = y
        p0.z = z
        p1 = Point()
        p1.x = tx
        p1.y = ty
        p1.z = tz
        m.points = [p0, p1]

        self.pub.publish(m)

    @staticmethod
    def _safe(v, fallback):
        try:
            fv = float(v)
        except Exception:
            return float(fallback)
        if math.isfinite(fv):
            return fv
        return float(fallback)


def main(args=None):
    rclpy.init(args=args)
    node = TrajectoryGuidanceMarkerBridge()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
