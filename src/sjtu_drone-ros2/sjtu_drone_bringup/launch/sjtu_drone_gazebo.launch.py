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

import os
import math
import yaml

from ament_index_python.packages import get_package_share_directory, get_package_prefix
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, OpaqueFunction, ExecuteProcess, TimerAction
from launch.conditions import IfCondition, UnlessCondition
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from launch.launch_description_sources import PythonLaunchDescriptionSource

import xacro


def _normalize_namespace(ns: str) -> str:
    ns = (ns or '').strip()
    if not ns:
        return '/drone'
    if not ns.startswith('/'):
        ns = '/' + ns
    return ns


def _as_bool(text: str, default: bool = False) -> bool:
    if text is None:
        return default
    return str(text).strip().lower() in ('1', 'true', 'yes', 'y', 'on')


def _namespace_from_prefix(prefix: str, index: int) -> str:
    p = (prefix or 'drone_w').strip().strip('/')
    if not p:
        p = 'drone_w'
    return f'/{p}{index:02d}'


def _frame_ns(ns: str) -> str:
    return (ns or '').strip().lstrip('/')


def _linear_spawn_pose(index_zero_based: int, count: int, spacing_m: float):
    if count <= 3:
        cols = count
    else:
        cols = int(math.ceil(math.sqrt(float(count))))
    rows = int(math.ceil(float(count) / float(cols)))

    row = int(index_zero_based // cols)
    col = int(index_zero_based % cols)

    x_center = 0.5 * float(cols - 1)
    y_center = 0.5 * float(rows - 1)
    x = (float(col) - x_center) * spacing_m
    y = (y_center - float(row)) * spacing_m
    z = 0.05
    return x, y, z


def setup_drone_nodes(context, use_sim_time, xacro_file, yaml_file_path):
    takeoff_hover_height = LaunchConfiguration("takeoff_hover_height").perform(context)
    takeoff_vertical_speed = LaunchConfiguration("takeoff_vertical_speed").perform(context)

    robot_description_config = xacro.process_file(
        xacro_file,
        mappings={
            "params_path": yaml_file_path,
            "takeoff_hover_height": takeoff_hover_height,
            "takeoff_vertical_speed": takeoff_vertical_speed,
        },
    )
    robot_desc = robot_description_config.toxml()

    model_ns = _normalize_namespace(LaunchConfiguration('drone_namespace').perform(context))

    multi_drone_count = int(LaunchConfiguration('multi_drone_count').perform(context))
    multi_drone_spacing_m = float(LaunchConfiguration('multi_drone_spacing_m').perform(context))
    multi_drone_namespace_prefix = LaunchConfiguration('multi_drone_namespace_prefix').perform(context)
    multi_drone_spawn_tags = _as_bool(LaunchConfiguration('multi_drone_spawn_tags').perform(context), True)
    use_world_tag_as_first = _as_bool(LaunchConfiguration('multi_drone_use_world_tag_as_first').perform(context), True)

    # Get absolute path to spawn executables
    spawn_drone_exe = os.path.join(get_package_prefix('sjtu_drone_bringup'), 'bin', 'spawn_drone')
    spawn_tag_exe = os.path.join(get_package_prefix('sjtu_drone_bringup'), 'bin', 'spawn_apriltag')

    if multi_drone_count < 1:
        multi_drone_count = 1

    actions = []
    # Avoid spawn queue contention: spawn all drones first, then tags.
    base_spawn_delay_sec = 3.0
    drone_spawn_step_sec = 2.0
    tag_phase_offset_sec = base_spawn_delay_sec + (drone_spawn_step_sec * float(multi_drone_count)) + 1.0
    tag_spawn_step_sec = 1.5
    for i in range(multi_drone_count):
        idx = i + 1
        ns = model_ns if multi_drone_count == 1 else _namespace_from_prefix(multi_drone_namespace_prefix, idx)
        ns_frame = _frame_ns(ns)
        x, y, z = _linear_spawn_pose(i, multi_drone_count, multi_drone_spacing_m)
        entity_name = f'drone_{idx:02d}'

        spawn_delay_sec = base_spawn_delay_sec + (drone_spawn_step_sec * float(i))

        actions.extend([
            Node(
                package='robot_state_publisher',
                executable='robot_state_publisher',
                name=f'robot_state_publisher_{idx:02d}',
                namespace=ns,
                output='screen',
                parameters=[{'use_sim_time': use_sim_time, 'robot_description': robot_desc, 'frame_prefix': ns_frame + '/'}],
                arguments=[robot_desc]
            ),
            Node(
                package='joint_state_publisher',
                executable='joint_state_publisher',
                name=f'joint_state_publisher_{idx:02d}',
                namespace=ns,
                output='screen',
            ),
            TimerAction(
                period=spawn_delay_sec,
                actions=[
                    ExecuteProcess(
                        cmd=[spawn_drone_exe, robot_desc, ns, f'{x:.3f}', f'{y:.3f}', f'{z:.3f}', '0.0', entity_name],
                        output='screen'
                    )
                ]
            ),
            Node(
                package='tf2_ros',
                executable='static_transform_publisher',
                name=f'static_tf_{idx:02d}',
                arguments=['0', '0', '0', '0', '0', '0', 'world', f'{ns_frame}/odom'],
                output='screen'
            ),
        ])

        if multi_drone_spawn_tags:
            tag_name = f'apriltag_{idx:02d}'
            pad_frame = f'{ns_frame}/landing_pad'
            actions.append(
                Node(
                    package='tf2_ros',
                    executable='static_transform_publisher',
                    name=f'static_tf_pad_{idx:02d}',
                    arguments=[f'{x:.3f}', f'{y:.3f}', '0.0', '0', '0', '0', 'world', pad_frame],
                    output='screen'
                )
            )
            if use_world_tag_as_first and idx == 1:
                continue
            tag_spawn_delay_sec = tag_phase_offset_sec + (tag_spawn_step_sec * float(i))
            actions.append(
                TimerAction(
                    period=tag_spawn_delay_sec,
                    actions=[
                        ExecuteProcess(
                            cmd=[spawn_tag_exe, tag_name, f'{x:.3f}', f'{y:.3f}', '0.0', '0.0'],
                            output='screen'
                        )
                    ]
                )
            )

    return actions


def generate_launch_description():
    use_sim_time = LaunchConfiguration("use_sim_time", default="true")

    yaml_file_path = os.path.join(
        get_package_share_directory('sjtu_drone_bringup'),
        'config', 'drone.yaml'
    )

    with open(yaml_file_path, 'r') as f:
        yaml_dict = yaml.load(f, Loader=yaml.FullLoader)
        default_ns = _normalize_namespace(yaml_dict["namespace"])

    drone_namespace = DeclareLaunchArgument(
        "drone_namespace",
        default_value=default_ns,
        description="Drone ROS namespace (e.g. /drone, /drone_w01)",
    )
    multi_drone_count = DeclareLaunchArgument(
        'multi_drone_count',
        default_value='1',
        description='Number of drones to spawn in one Gazebo world',
    )
    multi_drone_spacing_m = DeclareLaunchArgument(
        'multi_drone_spacing_m',
        default_value='3.0',
        description='Spacing between spawned drones on X axis (m)',
    )
    multi_drone_namespace_prefix = DeclareLaunchArgument(
        'multi_drone_namespace_prefix',
        default_value='drone_w',
        description='Namespace prefix used when multi_drone_count > 1',
    )
    multi_drone_spawn_tags = DeclareLaunchArgument(
        'multi_drone_spawn_tags',
        default_value='true',
        choices=['true', 'false'],
        description='Spawn one landing tag per drone',
    )
    multi_drone_use_world_tag_as_first = DeclareLaunchArgument(
        'multi_drone_use_world_tag_as_first',
        default_value='false',
        choices=['true', 'false'],
        description='Reuse world built-in tag as first drone tag',
    )
    use_gui = DeclareLaunchArgument("use_gui", default_value="true", choices=["true", "false"],
                                    description="Whether to execute gzclient")
    pre_kill_gazebo = DeclareLaunchArgument(
        'pre_kill_gazebo',
        default_value='true',
        choices=['true', 'false'],
        description='Kill stale gzserver/gzclient before launching Gazebo',
    )
    takeoff_hover_height = DeclareLaunchArgument(
        "takeoff_hover_height",
        default_value="1.0",
        description="Target altitude increase (m) after takeoff",
    )
    takeoff_vertical_speed = DeclareLaunchArgument(
        "takeoff_vertical_speed",
        default_value="1.0",
        description="Vertical climb command used during takeoff",
    )
    xacro_file_name = "sjtu_drone.urdf.xacro"
    pkg_gazebo_ros = get_package_share_directory('gazebo_ros')
    xacro_file = os.path.join(
        get_package_share_directory("sjtu_drone_description"),
        "urdf", xacro_file_name
    )

    world_file_default = os.path.join(
        get_package_share_directory("sjtu_drone_description"),
        "worlds", "landingPad.world"
    )

    world_file = LaunchConfiguration('world', default=world_file_default)

    world = DeclareLaunchArgument(
        name='world',
        default_value=world_file_default,
        description='Full path to world file to load'
    )

    def launch_gzclient(context, *args, **kwargs):
        if context.launch_configurations.get('use_gui') == 'true':
            return [IncludeLaunchDescription(
                PythonLaunchDescriptionSource(
                    os.path.join(pkg_gazebo_ros, 'launch', 'gzclient.launch.py')
                ),
                launch_arguments={'verbose': 'true'}.items()
            )]
        return []

    return LaunchDescription([
        world,
        use_gui,
        pre_kill_gazebo,
        drone_namespace,
        multi_drone_count,
        multi_drone_spacing_m,
        multi_drone_namespace_prefix,
        multi_drone_spawn_tags,
        multi_drone_use_world_tag_as_first,
        takeoff_hover_height,
        takeoff_vertical_speed,

        ExecuteProcess(
            cmd=['bash', '-lc', 'pkill -9 -f "(^|/)gzserver([[:space:]]|$)" >/dev/null 2>&1 || true; pkill -9 -f "(^|/)gzclient([[:space:]]|$)" >/dev/null 2>&1 || true'],
            output='screen',
            condition=IfCondition(LaunchConfiguration('pre_kill_gazebo')),
        ),

        TimerAction(
            period=2.0,
            condition=IfCondition(LaunchConfiguration('pre_kill_gazebo')),
            actions=[
                IncludeLaunchDescription(
                    PythonLaunchDescriptionSource(
                        os.path.join(pkg_gazebo_ros, 'launch', 'gzserver.launch.py')
                    ),
                    launch_arguments={'world': world_file,
                                      'verbose': "true",
                                      'extra_gazebo_args': 'verbose'}.items()
                ),
                OpaqueFunction(function=launch_gzclient),
                OpaqueFunction(
                    function=setup_drone_nodes,
                    kwargs={
                        "use_sim_time": use_sim_time,
                        "xacro_file": xacro_file,
                        "yaml_file_path": yaml_file_path,
                    },
                ),
            ],
        ),

        TimerAction(
            period=0.0,
            condition=UnlessCondition(LaunchConfiguration('pre_kill_gazebo')),
            actions=[
                IncludeLaunchDescription(
                    PythonLaunchDescriptionSource(
                        os.path.join(pkg_gazebo_ros, 'launch', 'gzserver.launch.py')
                    ),
                    launch_arguments={'world': world_file,
                                      'verbose': "true",
                                      'extra_gazebo_args': 'verbose'}.items()
                ),
                OpaqueFunction(function=launch_gzclient),
                OpaqueFunction(
                    function=setup_drone_nodes,
                    kwargs={
                        "use_sim_time": use_sim_time,
                        "xacro_file": xacro_file,
                        "yaml_file_path": yaml_file_path,
                    },
                ),
            ],
        ),
    ])
