from launch import LaunchDescription
from launch.actions import ExecuteProcess, DeclareLaunchArgument
from launch_ros.actions import Node
from launch.substitutions import LaunchConfiguration
from ament_index_python.packages import get_package_share_directory
import os
import xacro

def generate_launch_description():
    pkg_share = get_package_share_directory('ros2_description')
    xacro_file = os.path.join(pkg_share, 'urdf', 'robot_core.xacro')
    world_file = os.path.join(pkg_share, 'worlds', 'AI_Center3.world')

    declare_world_arg = DeclareLaunchArgument(
        'world',
        default_value=world_file,
        description='Gazebo world file to load'
    )
    world = LaunchConfiguration('world')

    # xacro -> urdf
    robot_description_config = xacro.process_file(xacro_file).toxml()

    return LaunchDescription([
        declare_world_arg,
        ExecuteProcess(
            cmd=[
                'gazebo', '--verbose',
                '-s', 'libgazebo_ros_factory.so',
                world
            ],
            output='screen'
        ),
        Node(
            package='robot_state_publisher',
            executable='robot_state_publisher',
            name='robot_state_publisher',
            output='screen',
            parameters=[{
                'use_sim_time': True,
                'robot_description': robot_description_config
            }]
        ),
        Node(
            package='gazebo_ros',
            executable='spawn_entity.py',
            arguments=[
                '-topic',  'robot_description',
                '-entity', 'drone',
                '-x', '0.0', '-y', '0.0', '-z', '0.2'
            ],
            output='screen'
        ),
    ])
