#!/usr/bin/env python3
"""
cmd_vel_extractor.py
4대 드론(drone_w01~w04 또는 drone)의 cmd_vel 토픽을 수신하고 로깅
"""
import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist
import csv
from pathlib import Path
from datetime import datetime
import sys

class CmdVelExtractor(Node):
    def __init__(self):
        super().__init__('cmd_vel_extractor')
        
        self.output_dir = Path.home() / ".ros" / "cmd_vel_logs"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = self.output_dir / f"cmd_vel_log_{timestamp}.csv"
        
        # CSV 파일 초기화
        with open(self.log_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp_ns', 'drone_name', 'vx', 'vy', 'vz', 'angular_z', 'time_sec'])
        
        self.start_time_ns = None
        self._subs = []
        self.drone_namespaces = ['drone_w01', 'drone_w02', 'drone_w03', 'drone_w04', 'drone']
        
        self.get_logger().info(f"cmd_vel Extractor started")
        self.get_logger().info(f"Output file: {self.log_file}")
        
        # 각 드론 네임스페이스에 대해 구독
        for ns in self.drone_namespaces:
            topic = f"/{ns}/cmd_vel"
            try:
                sub = self.create_subscription(
                    Twist,
                    topic,
                    lambda msg, ns=ns: self.cmd_vel_callback(msg, ns),
                    10
                )
                self._subs.append(sub)
                self.get_logger().info(f"Subscribed to {topic}")
            except Exception as e:
                self.get_logger().warn(f"Failed to subscribe to {topic}: {e}")
    
    def cmd_vel_callback(self, msg: Twist, drone_name: str):
        """cmd_vel 메시지 콜백"""
        if self.start_time_ns is None:
            self.start_time_ns = self.get_clock().now().nanoseconds
        
        current_time_ns = self.get_clock().now().nanoseconds
        time_sec = (current_time_ns - self.start_time_ns) / 1e9
        
        vx = msg.linear.x
        vy = msg.linear.y
        vz = msg.linear.z
        angular_z = msg.angular.z
        
        # CSV에 기록
        with open(self.log_file, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([current_time_ns, drone_name, vx, vy, vz, angular_z, time_sec])
        
        self.get_logger().debug(f"[{drone_name}] vx={vx:.2f}, vy={vy:.2f}, vz={vz:.2f}, w_z={angular_z:.2f}")

def main(args=None):
    rclpy.init(args=args)
    extractor = CmdVelExtractor()
    
    try:
        rclpy.spin(extractor)
    except KeyboardInterrupt:
        extractor.get_logger().info(f"Shutting down. Log saved to {extractor.log_file}")
    finally:
        extractor.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
