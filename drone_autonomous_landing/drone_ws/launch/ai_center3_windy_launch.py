from launch import LaunchDescription
from launch.actions import ExecuteProcess
import os

def generate_launch_description():
    pkg_share = os.path.join(os.path.dirname(__file__), '..', 'src', 'drone_description')
    world_path = os.path.join(pkg_share, 'worlds', 'AI_Center3_windy.world')

    gzserver = ExecuteProcess(
        cmd=['gzserver', world_path],
        output='screen'
    )

    gzclient = ExecuteProcess(
        cmd=['gzclient'],
        output='screen'
    )

    return LaunchDescription([gzserver, gzclient])
