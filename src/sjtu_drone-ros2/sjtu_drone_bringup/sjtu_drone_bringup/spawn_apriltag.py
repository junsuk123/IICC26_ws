#!/usr/bin/env python3

import math
import sys

import rclpy
from gazebo_msgs.srv import SpawnEntity


def build_tag_sdf(model_name: str) -> str:
    return f'''<?xml version="1.0"?>
<sdf version="1.6">
  <model name="{model_name}">
    <static>true</static>
    <include>
      <uri>model://Apriltag36_11_00000</uri>
    </include>
  </model>
</sdf>
'''


def main(args=None):
    if len(sys.argv) < 2:
        print('Usage: spawn_apriltag <model_name> [x y z yaw]')
        return

    model_name = sys.argv[1]
    x = float(sys.argv[2]) if len(sys.argv) >= 3 else 0.0
    y = float(sys.argv[3]) if len(sys.argv) >= 4 else 0.0
    z = float(sys.argv[4]) if len(sys.argv) >= 5 else 0.0
    yaw = float(sys.argv[5]) if len(sys.argv) >= 6 else 0.0

    rclpy.init(args=args)
    node = rclpy.create_node('spawn_apriltag')
    cli = node.create_client(SpawnEntity, '/spawn_entity')

    req = SpawnEntity.Request()
    req.name = model_name
    req.xml = build_tag_sdf(model_name)
    req.robot_namespace = ''
    req.reference_frame = 'world'
    req.initial_pose.position.x = x
    req.initial_pose.position.y = y
    req.initial_pose.position.z = z
    req.initial_pose.orientation.z = math.sin(0.5 * yaw)
    req.initial_pose.orientation.w = math.cos(0.5 * yaw)

    while not cli.wait_for_service(timeout_sec=1.0):
        node.get_logger().info('spawn service unavailable, waiting...')

    future = cli.call_async(req)
    rclpy.spin_until_future_complete(node, future)

    if future.result() is not None:
        node.get_logger().info(f'Result {future.result().success} {future.result().status_message}')
    else:
        node.get_logger().error(f'Service call failed {future.exception()}')

    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
