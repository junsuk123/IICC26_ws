from launch import LaunchDescription
from launch.actions import ExecuteProcess, DeclareLaunchArgument
from launch_ros.actions import Node
from launch.substitutions import LaunchConfiguration
from ament_index_python.packages import get_package_share_directory
import os
import xacro

def generate_launch_description():
    pkg_share = get_package_share_directory('drone')
    xacro_file = os.path.join(pkg_share, 'urdf', 'sjtu_drone.urdf.xacro')
    world_file = os.path.join(pkg_share, 'worlds', 'AI_Center3.world')

    # Use an absolute world file path from this workspace so Gazebo loads
    # the intended world/model files (avoids picking an unrelated install).
    declare_world_arg = DeclareLaunchArgument(
        'world',
        default_value=world_file,
        description='Gazebo world file to load (absolute path)'
    )
    # Resolve the LaunchConfiguration at launch time; but when launching
    # from a wrapped script we prefer the absolute default path. The
    # ExecuteProcess below will accept either the LaunchConfiguration or
    # the resolved string.
    world = LaunchConfiguration('world')

    # xacro -> urdf
    robot_description_config = xacro.process_file(xacro_file).toxml()

    return LaunchDescription([
        declare_world_arg,
        # Use the absolute world file path from this package so Gazebo loads
        # the workspace's world (avoids accidentally using a different
        # workspace's install). Users can still override the 'world'
        # launch-argument with an explicit path if needed.
        ExecuteProcess(
            cmd=[
                'gazebo', '--verbose',
                '-s', 'libgazebo_ros_factory.so',
                world_file
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
