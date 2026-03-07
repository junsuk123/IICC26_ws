#!/usr/bin/env python3
"""Launch wrapper to start the wind publisher script alongside other ROS2 nodes.

This launch file executes the Python fallback publisher `scripts/wind_publisher_py.py`.
It is intentionally lightweight and uses ExecuteProcess to invoke the script with
the same Python interpreter as the environment.

Usage:
  ros2 launch sjtu_drone-ros2 wind_publisher_launch.py rate:=10

Arguments:
  rate: publish rate in Hz (default 10)
"""
import os

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, LogInfo
from launch.substitutions import LaunchConfiguration


def generate_launch_description():
    rate = LaunchConfiguration('rate', default='10')

    this_dir = os.path.dirname(__file__)
    # script is located at ../scripts/wind_publisher_py.py relative to this launch file
    script_path = os.path.abspath(os.path.join(this_dir, '..', 'scripts', 'wind_publisher_py.py'))

    if not os.path.isfile(script_path):
        return LaunchDescription([
            LogInfo(msg=['Wind publisher script not found: ', script_path]),
        ])

    # Build command: python3 <script> --rate <rate>
    cmd = ['python3', script_path, '--rate', str(rate)]

    # Execute the script as a separate process; output to screen for visibility
    exec_proc = ExecuteProcess(cmd=cmd, output='screen', shell=False)

    ld = LaunchDescription()
    ld.add_action(DeclareLaunchArgument('rate', default_value='10', description='Publish rate (Hz)'))
    ld.add_action(LogInfo(msg=['Starting wind_publisher_py.py at rate=', rate]))
    ld.add_action(exec_proc)

    return ld
