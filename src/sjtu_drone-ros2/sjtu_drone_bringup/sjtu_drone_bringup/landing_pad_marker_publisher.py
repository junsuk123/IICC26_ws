#!/usr/bin/env python3

import math

import rclpy
from rclpy.node import Node

from visualization_msgs.msg import Marker


class LandingPadMarkerPublisher(Node):
    def __init__(self):
        super().__init__('landing_pad_marker_publisher')

        self.declare_parameter('topic', '/observe/w01/landing_pad_marker')
        self.declare_parameter('frame_id', 'drone_w01/landing_pad')
        self.declare_parameter('rate_hz', 1.0)
        self.declare_parameter('size_x', 1.2)
        self.declare_parameter('size_y', 1.2)
        self.declare_parameter('size_z', 0.05)
        self.declare_parameter('color_r', 0.18)
        self.declare_parameter('color_g', 0.70)
        self.declare_parameter('color_b', 0.28)
        self.declare_parameter('color_a', 0.85)

        self.topic = self.get_parameter('topic').get_parameter_value().string_value
        self.frame_id = self.get_parameter('frame_id').get_parameter_value().string_value
        self.rate_hz = self._safe_float(self.get_parameter('rate_hz').value, 1.0)
        self.size_x = self._safe_float(self.get_parameter('size_x').value, 1.2)
        self.size_y = self._safe_float(self.get_parameter('size_y').value, 1.2)
        self.size_z = self._safe_float(self.get_parameter('size_z').value, 0.05)
        self.color_r = self._safe_float(self.get_parameter('color_r').value, 0.18)
        self.color_g = self._safe_float(self.get_parameter('color_g').value, 0.70)
        self.color_b = self._safe_float(self.get_parameter('color_b').value, 0.28)
        self.color_a = self._safe_float(self.get_parameter('color_a').value, 0.85)

        if not math.isfinite(self.rate_hz) or self.rate_hz <= 0.0:
            self.rate_hz = 1.0

        self.publisher = self.create_publisher(Marker, self.topic, 10)
        self.timer = self.create_timer(1.0 / self.rate_hz, self._publish_marker)

        self.get_logger().info(
            f'Landing pad marker publisher started: {self.topic} (frame={self.frame_id})'
        )

    def _publish_marker(self):
        marker = Marker()
        marker.header.stamp = self.get_clock().now().to_msg()
        marker.header.frame_id = self.frame_id
        marker.ns = 'landing_pad'
        marker.id = 0
        marker.type = Marker.CUBE
        marker.action = Marker.ADD
        marker.pose.orientation.w = 1.0
        marker.scale.x = self.size_x
        marker.scale.y = self.size_y
        marker.scale.z = self.size_z
        marker.color.r = self.color_r
        marker.color.g = self.color_g
        marker.color.b = self.color_b
        marker.color.a = self.color_a
        self.publisher.publish(marker)

    @staticmethod
    def _safe_float(value, fallback):
        try:
            numeric = float(value)
        except Exception:
            return float(fallback)
        if math.isfinite(numeric):
            return numeric
        return float(fallback)


def main(args=None):
    rclpy.init(args=args)
    node = LandingPadMarkerPublisher()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()