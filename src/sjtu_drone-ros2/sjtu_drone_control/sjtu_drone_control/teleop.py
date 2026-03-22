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

import rclpy
from rclpy.node import Node
from geometry_msgs.msg import Twist, Vector3
from std_msgs.msg import Empty
import sys
import termios
import tty


def _normalize_namespace(ns: str) -> str:
    ns = (ns or '').strip()
    if not ns:
        return '/drone'
    if not ns.startswith('/'):
        ns = '/' + ns
    return ns


def _namespace_from_prefix(prefix: str, index: int) -> str:
    p = (prefix or 'drone_w').strip().strip('/')
    if not p:
        p = 'drone_w'
    return f'/{p}{index:02d}'


MSG = """
Control Your Drone!
---------------------------
Moving around:
        w
    a   s    d
        x

t/l: takeoff/land (upper/lower case)
q/e : increase/decrease linear and angular velocity (upper/lower case)
A/D: rotate left/right
r/f : rise/fall (upper/lower case)

---------------------------
CTRL-C to quit
---------------------------

"""


class TeleopNode(Node):
    def __init__(self) -> None:
        super().__init__('teleop_node')

        self.declare_parameter('multi_drone_count', 1)
        self.declare_parameter('multi_drone_namespace_prefix', 'drone_w')
        self.declare_parameter('primary_namespace', '')

        # Publishers
        self.cmd_vel_publisher = self.create_publisher(Twist, 'cmd_vel', 10)
        self.takeoff_publisher = self.create_publisher(Empty, 'takeoff', 10)
        self.land_publisher = self.create_publisher(Empty, 'land', 10)

        self.cmd_vel_followers = []
        self.takeoff_followers = []
        self.land_followers = []

        multi_count = int(self.get_parameter('multi_drone_count').value)
        ns_prefix = str(self.get_parameter('multi_drone_namespace_prefix').value)
        primary_ns_param = str(self.get_parameter('primary_namespace').value)
        primary_ns = _normalize_namespace(primary_ns_param if primary_ns_param else self.get_namespace())

        if multi_count > 1:
            all_ns = [_namespace_from_prefix(ns_prefix, i + 1) for i in range(multi_count)]
            followers = [ns for ns in all_ns if ns != primary_ns]
            for ns in followers:
                self.cmd_vel_followers.append(self.create_publisher(Twist, f'{ns}/cmd_vel', 10))
                self.takeoff_followers.append(self.create_publisher(Empty, f'{ns}/takeoff', 10))
                self.land_followers.append(self.create_publisher(Empty, f'{ns}/land', 10))
            self.get_logger().info(
                'Multi-drone teleop enabled: primary=%s followers=%s'
                % (primary_ns, ','.join(followers))
            )

        # Velocity parameters
        self.linear_velocity = 0.0
        self.angular_velocity = 0.0
        self.linear_increment = 0.05
        self.angular_increment = 0.05
        self.max_linear_velocity = 1.0
        self.max_angular_velocity = 1.0

        # Start a timer to listen to keyboard inputs
        self.create_timer((1/30), self.read_keyboard_input)

    def get_velocity_msg(self) -> str:
        return "Linear Velocity: " + str(self.linear_velocity) + "\nAngular Velocity: " \
            + str(self.angular_velocity) + "\n"

    def read_keyboard_input(self) -> None:
        """
        Read keyboard inputs and publish corresponding commands
        """
        while rclpy.ok():
            # Print the instructions
            print(MSG+self.get_velocity_msg())
            # Implement a non-blocking keyboard read
            key = self.get_key()
            # Handle velocity changes
            if key.lower() == 'q':
                self.linear_velocity = min(self.linear_velocity + self.linear_increment,
                                           self.max_linear_velocity)
                self.angular_velocity = min(self.angular_velocity + self.angular_increment,
                                            self.max_angular_velocity)
            elif key.lower() == 'e':
                self.linear_velocity = max(self.linear_velocity - self.linear_increment,
                                           -self.max_linear_velocity)
                self.angular_velocity = max(self.angular_velocity - self.angular_increment,
                                            -self.max_angular_velocity)
            elif key.lower() == 'w':
                # Move forward
                linear_vec = Vector3()
                linear_vec.x = self.linear_velocity
                self.publish_cmd_vel(linear_vec)
            elif key.lower() == 's':
                # Hover
                self.publish_cmd_vel()
            elif key.lower() == 'x':
                # Move backward
                linear_vec = Vector3()
                linear_vec.x = -self.linear_velocity
                self.publish_cmd_vel(linear_vec)
            elif key == 'a':
                # Move Left
                linear_vec = Vector3()
                linear_vec.y = self.linear_velocity
                self.publish_cmd_vel(linear_vec)
            elif key == 'd':
                # Move right
                linear_vec = Vector3()
                linear_vec.y = -self.linear_velocity
                self.publish_cmd_vel(linear_vec)
            elif key == 'A':
                # Move Left
                angular_vec = Vector3()
                angular_vec.z = self.angular_velocity
                self.publish_cmd_vel(angular_vec=angular_vec)
            elif key == 'D':
                # Move right
                angular_vec = Vector3()
                angular_vec.z = -self.angular_velocity
                self.publish_cmd_vel(angular_vec=angular_vec)
            elif key.lower() == 'r':
                # Rise
                linear_vec = Vector3()
                linear_vec.z = self.linear_velocity
                self.publish_cmd_vel(linear_vec)
            elif key.lower() == 'f':
                # Fall
                linear_vec = Vector3()
                linear_vec.z = -self.angular_velocity
                self.publish_cmd_vel(linear_vec)
            # Handle other keys for different movements
            elif key.lower() == 't':
                # Takeoff
                msg = Empty()
                self.takeoff_publisher.publish(msg)
                for pub in self.takeoff_followers:
                    pub.publish(msg)
            elif key.lower() == 'l':
                # Land
                self.publish_cmd_vel()
                msg = Empty()
                self.land_publisher.publish(msg)
                for pub in self.land_followers:
                    pub.publish(msg)

    def get_key(self) -> str:
        """
        Function to capture keyboard input
        """
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch

    def publish_cmd_vel(self, linear_vec: Vector3 = Vector3(),
                        angular_vec: Vector3 = Vector3()) -> None:
        """
        Publish a Twist message to cmd_vel topic
        """
        twist = Twist(linear=linear_vec, angular=angular_vec)
        self.cmd_vel_publisher.publish(twist)
        for pub in self.cmd_vel_followers:
            pub.publish(twist)


def main(args=None):
    rclpy.init(args=args)
    teleop_node = TeleopNode()
    rclpy.spin(teleop_node)
    teleop_node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
