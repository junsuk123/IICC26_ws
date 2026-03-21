#!/usr/bin/env python3
# Copyright 2023 Georg Novotny
#
# Licensed under the GNU GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -*- coding: utf-8 -*-
import sys
import math
import rclpy
from gazebo_msgs.srv import SpawnEntity


def main(args=None):
    rclpy.init(args=args)
    node = rclpy.create_node('spawn_drone')
    cli = node.create_client(SpawnEntity, '/spawn_entity')

    if len(sys.argv) < 3:
        node.get_logger().error('Usage: spawn_drone <robot_xml> <namespace> [x y z yaw entity_name]')
        node.destroy_node()
        rclpy.shutdown()
        return

    content = sys.argv[1]
    namespace = sys.argv[2]

    x = 0.0
    y = 0.0
    z = 0.0
    yaw = 0.0
    entity_name = namespace.strip('/') if namespace else 'drone'

    if len(sys.argv) >= 6:
        x = float(sys.argv[3])
        y = float(sys.argv[4])
        z = float(sys.argv[5])
    if len(sys.argv) >= 7:
        yaw = float(sys.argv[6])
    if len(sys.argv) >= 8:
        entity_name = sys.argv[7]

    req = SpawnEntity.Request()
    req.name = entity_name
    req.xml = content
    req.robot_namespace = namespace
    req.reference_frame = "world"
    req.initial_pose.position.x = x
    req.initial_pose.position.y = y
    req.initial_pose.position.z = z
    req.initial_pose.orientation.z = math.sin(0.5 * yaw)
    req.initial_pose.orientation.w = math.cos(0.5 * yaw)

    while not cli.wait_for_service(timeout_sec=1.0):
        node.get_logger().info('service not available, waiting again...')

    future = cli.call_async(req)
    rclpy.spin_until_future_complete(node, future)

    if future.result() is not None:
        node.get_logger().info(
            'Result ' + str(future.result().success) + " " + future.result().status_message)
    else:
        node.get_logger().info('Service call failed %r' % (future.exception(),))

    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
