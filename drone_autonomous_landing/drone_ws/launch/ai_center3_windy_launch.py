from launch import LaunchDescription
from launch.actions import ExecuteProcess
import os

def generate_launch_description():
    # workspace-relative paths
    workspace_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    pkg_share = os.path.join(workspace_root, 'src', 'drone_description')
    world_path = os.path.join(pkg_share, 'worlds', 'AI_Center3_windy.world')
    models_dir = os.path.join(pkg_share, 'models')

    # Ensure Gazebo can find local models when the user didn't source the workspace
    old = os.environ.get('GAZEBO_MODEL_PATH', '')
    new = models_dir if not old else old + os.pathsep + models_dir
    os.environ['GAZEBO_MODEL_PATH'] = new

    # ensure Gazebo can find our plugin libraries
    plugin_dir = os.path.join(pkg_share, 'plugins')
    old_ld = os.environ.get('LD_LIBRARY_PATH', '')
    new_ld = plugin_dir if not old_ld else old_ld + os.pathsep + plugin_dir
    os.environ['LD_LIBRARY_PATH'] = new_ld

    gzserver = ExecuteProcess(
        cmd=['gzserver', world_path],
        output='screen',
        env=os.environ.copy()
    )

    gzclient = ExecuteProcess(
        cmd=['gzclient'],
        output='screen',
        env=os.environ.copy()
    )

    return LaunchDescription([gzserver, gzclient])
