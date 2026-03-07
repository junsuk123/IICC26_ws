#!/usr/bin/env python3
"""Launch wrapper to start the wind publisher script (placed in sjtu_drone-ros2) from sjtu_drone_bringup package.

This duplicate launch is provided so users can run:
  ros2 launch sjtu_drone_bringup wind_publisher_launch.py rate:=10

It executes the Python publisher script installed in the workspace source tree.
"""
import os

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, LogInfo
from launch.substitutions import LaunchConfiguration


def generate_launch_description():
    rate = LaunchConfiguration('rate', default='10')

    # script path: ../../sjtu_drone-ros2/scripts/wind_publisher_py.py relative to this package
    this_dir = os.path.dirname(__file__)
    script_path = os.path.abspath(os.path.join(this_dir, '..', '..', 'sjtu_drone-ros2', 'scripts', 'wind_publisher_py.py'))

    if not os.path.isfile(script_path):
        return LaunchDescription([
            LogInfo(msg=['Wind publisher script not found: ', script_path]),
        ])

    cmd = ['python3', script_path, '--rate', str(rate)]
    exec_proc = ExecuteProcess(cmd=cmd, output='screen', shell=False)

    ld = LaunchDescription()
    ld.add_action(DeclareLaunchArgument('rate', default_value='10', description='Publish rate (Hz)'))
    ld.add_action(LogInfo(msg=['Starting wind_publisher_py.py at rate=', rate]))
    ld.add_action(exec_proc)

    return ld
