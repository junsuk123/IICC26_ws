#!/usr/bin/env python3
"""
gt_pose_analyzer.py
4대 드론의 Gazebo ground_truth 위치를 수신하고, 5초 window로 위치 변화(dxy) 계산
"""
import rclpy
from rclpy.node import Node
from nav_msgs.msg import Odometry
import csv
from pathlib import Path
from datetime import datetime
from collections import deque
import math

class GtPoseAnalyzer(Node):
    def __init__(self, window_size=5.0):
        """
        Args:
            window_size: 위치 변화를 계산할 시간 윈도우 (초)
        """
        super().__init__('gt_pose_analyzer')
        
        self.output_dir = Path.home() / ".ros" / "gt_pose_logs"
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_file = self.output_dir / f"gt_pose_dxy_log_{timestamp}.csv"
        
        # CSV 파일 초기화
        with open(self.log_file, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['timestamp_ns', 'drone_name', 'x', 'y', 'z', 
                            'dx_5sec', 'dy_5sec', 'dxy_magnitude', 'time_sec'])
        
        self.start_time_ns = None
        self.window_size = window_size
        self._subs = []
        self.drone_namespaces = ['drone_w01', 'drone_w02', 'drone_w03', 'drone_w04', 'drone']
        
        # 각 드론별 센서 데이터 버퍼 (time_ns, x, y 저장)
        self.drone_buffers = {ns: deque(maxlen=1000) for ns in self.drone_namespaces}
        
        self.get_logger().info(f"gt_pose Analyzer started (window_size={window_size}s)")
        self.get_logger().info(f"Output file: {self.log_file}")
        
        # 각 드론 네임스페이스에 대해 구독
        for ns in self.drone_namespaces:
            # Gazebo ground_truth/state 토픽 구독
            topic_name = f"/{ns}/ground_truth/state"
            sub = self.create_subscription(
                Odometry,
                topic_name,
                lambda msg, ns=ns: self.gt_pose_callback(msg, ns),
                10
            )
            self._subs.append(sub)
            self.get_logger().info(f"Created subscription to {topic_name}")
    
    def gt_pose_callback(self, msg: Odometry, drone_name: str):
        """ground_truth 오더메트리 콜백"""
        if self.start_time_ns is None:
            self.start_time_ns = self.get_clock().now().nanoseconds
        
        current_time_ns = self.get_clock().now().nanoseconds
        time_sec = (current_time_ns - self.start_time_ns) / 1e9
        
        x = msg.pose.pose.position.x
        y = msg.pose.pose.position.y
        z = msg.pose.pose.position.z
        
        # 버퍼에 저장
        self.drone_buffers[drone_name].append((current_time_ns, x, y, z))
        
        # 5초 윈도우 내의 데이터로 dxy 계산
        dx_5sec = 0.0
        dy_5sec = 0.0
        
        buffer = self.drone_buffers[drone_name]
        if len(buffer) > 1:
            oldest_time = current_time_ns - int(self.window_size * 1e9)
            
            # 5초 윈도우 내에서 처음과 마지막 위치 찾기
            first_x, first_y = None, None
            for ts, px, py, pz in buffer:
                if ts >= oldest_time:
                    if first_x is None:
                        first_x, first_y = px, py
            
            if first_x is not None:
                dx_5sec = x - first_x
                dy_5sec = y - first_y
        
        dxy_magnitude = math.sqrt(dx_5sec**2 + dy_5sec**2)
        
        # CSV에 기록
        with open(self.log_file, 'a', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([current_time_ns, drone_name, x, y, z, 
                            dx_5sec, dy_5sec, dxy_magnitude, time_sec])
        
        if (int(time_sec) % 5) == 0:  # 5초마다 출력
            self.get_logger().info(f"[{drone_name}] pos=({x:.2f}, {y:.2f}), "
                                  f"dxy_5sec=({dx_5sec:.3f}, {dy_5sec:.3f}), "
                                  f"|dxy|={dxy_magnitude:.3f}")

def main(args=None):
    rclpy.init(args=args)
    analyzer = GtPoseAnalyzer(window_size=5.0)
    
    try:
        rclpy.spin(analyzer)
    except KeyboardInterrupt:
        analyzer.get_logger().info(f"Shutting down. Data saved to {analyzer.log_file}")
    finally:
        analyzer.destroy_node()
        rclpy.shutdown()

if __name__ == '__main__':
    main()
