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

import yaml
from ament_index_python.packages import get_package_share_directory, get_package_prefix
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, IncludeLaunchDescription, OpaqueFunction, ExecuteProcess, LogInfo
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node
from launch.substitutions import LaunchConfiguration
from launch.conditions import IfCondition


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


def _resolve_multi_ns_topic(template: str, ns: str, fallback: str, multi_mode: bool) -> str:
    raw = (template or '').strip()
    if not raw:
        return fallback
    # In multi-drone mode, plain absolute topics can accidentally pin all drones
    # to one namespace. Allow explicit templates via {ns}; otherwise use fallback.
    if multi_mode:
        if '{ns}' in raw:
            return raw.replace('{ns}', ns)
        return fallback
    return raw


def get_teleop_controller(context, *_, **__) -> Node:
    controller = context.launch_configurations["controller"]
    namespace = _normalize_namespace(LaunchConfiguration('drone_namespace').perform(context))
    multi_drone_count = int(LaunchConfiguration('multi_drone_count').perform(context))
    multi_drone_prefix = LaunchConfiguration('multi_drone_namespace_prefix').perform(context)
    teleop_params = [{
        'multi_drone_count': multi_drone_count,
        'multi_drone_namespace_prefix': multi_drone_prefix,
        'primary_namespace': namespace,
    }]

    if controller == "joystick":
        node = Node(
            package="sjtu_drone_control",
            executable="teleop_joystick",
            namespace=namespace,
            parameters=teleop_params,
            output="screen",
        )

    else:
        node = Node(
            package="sjtu_drone_control",
            executable="teleop",
            namespace=namespace,
            parameters=teleop_params,
            output="screen",
            prefix="xterm -e",
        )

    return [node]

def rviz_node_generator(context, rviz_path):
    """Return a Node action for RViz with namespace-aware AprilTag image topic."""
    if LaunchConfiguration('use_rviz').perform(context) != 'true':
        return []

    drone_ns = _normalize_namespace(LaunchConfiguration('drone_namespace').perform(context))
    multi_drone_count = int(LaunchConfiguration('multi_drone_count').perform(context))
    multi_drone_prefix = LaunchConfiguration('multi_drone_namespace_prefix').perform(context)
    drone_namespaces = [drone_ns]
    if multi_drone_count > 1:
        drone_namespaces = [_namespace_from_prefix(multi_drone_prefix, i + 1) for i in range(multi_drone_count)]

    fixed_frame_value = LaunchConfiguration('fixed_frame').perform(context)

    # Create a temporary RViz config with namespace-aware image/model displays
    import tempfile
    drone_urdf_file = os.path.join(get_package_share_directory('sjtu_drone_description'), 'urdf', 'sjtu_drone.urdf')

    def _build_image_display(ns: str) -> str:
        topic = f'{ns}/landing_tag_state_image'
        clean = ns.strip('/').replace('/', '_')
        return (
            '    - Class: rviz_default_plugins/Image\n'
            '      Enabled: true\n'
            '      Max Value: 1\n'
            '      Median window: 5\n'
            '      Min Value: 0\n'
            f'      Name: AprilTag Annotated {clean}\n'
            '      Normalize Range: true\n'
            '      Topic:\n'
            '        Depth: 5\n'
            '        Durability Policy: Volatile\n'
            '        History Policy: Keep Last\n'
            '        Reliability Policy: Reliable\n'
            f'        Value: {topic}\n'
            '      Value: true\n'
        )

    def _build_camera_display(ns: str, camera_name: str, topic_suffix: str) -> str:
        topic = f'{ns}/{topic_suffix}'
        clean = ns.strip('/').replace('/', '_')
        return (
            '    - Class: rviz_default_plugins/Image\n'
            '      Enabled: true\n'
            '      Max Value: 1\n'
            '      Median window: 5\n'
            '      Min Value: 0\n'
            f'      Name: {camera_name} {clean}\n'
            '      Normalize Range: true\n'
            '      Topic:\n'
            '        Depth: 5\n'
            '        Durability Policy: Volatile\n'
            '        History Policy: Keep Last\n'
            '        Reliability Policy: Reliable\n'
            f'        Value: {topic}\n'
            '      Value: true\n'
        )

    def _build_robot_model_display(ns: str) -> str:
        clean = ns.strip('/').replace('/', '_')
        tf_prefix = ns.strip('/')
        return (
            '    - Alpha: 1\n'
            '      Class: rviz_default_plugins/RobotModel\n'
            '      Collision Enabled: false\n'
            f'      Description File: {drone_urdf_file}\n'
            '      Description Source: File\n'
            '      Enabled: true\n'
            '      Links:\n'
            '        All Links Enabled: true\n'
            f'      Name: RobotModel {clean}\n'
            f'      TF Prefix: {tf_prefix}\n'
            '      Update Interval: 0\n'
            '      Value: true\n'
        )
    
    try:
        # Read the base RViz config
        with open(rviz_path, 'r') as f:
            rviz_config = f.read()

        # Keep base displays for the first namespace and append additional entries for others.
        rviz_config = rviz_config.replace('Value: /drone/landing_tag_state_image', f'Value: {drone_namespaces[0]}/landing_tag_state_image')
        rviz_config = rviz_config.replace('Value: /drone/front/image_raw', f'Value: {drone_namespaces[0]}/front/image_raw')
        rviz_config = rviz_config.replace('Value: /drone/bottom/image_raw', f'Value: {drone_namespaces[0]}/bottom/image_raw')

        extra_blocks = ''
        for ns in drone_namespaces:
            extra_blocks += _build_robot_model_display(ns)
        for ns in drone_namespaces[1:]:
            extra_blocks += _build_image_display(ns)
            extra_blocks += _build_camera_display(ns, 'Front Camera', 'front/image_raw')
            extra_blocks += _build_camera_display(ns, 'Bottom Camera', 'bottom/image_raw')

        if extra_blocks:
            rviz_config = rviz_config.replace('  Enabled: true\n  Global Options:', f'{extra_blocks}  Enabled: true\n  Global Options:', 1)
        
        # Write to a temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.rviz', delete=False) as tmp:
            tmp.write(rviz_config)
            temp_rviz_path = tmp.name
    except Exception as e:
        print(f"[bringup] Failed to create namespace-aware RViz config: {e}")
        print(f"[bringup] Using default RViz config at {rviz_path}")
        temp_rviz_path = rviz_path

    rviz_arguments = ['-d', temp_rviz_path]

    if fixed_frame_value:
        rviz_arguments.extend(['--fixed-frame', fixed_frame_value])

    return [
        Node(
            package='rviz2',
            executable='rviz2',
            name='rviz2',
            arguments=rviz_arguments,
            output='screen',
        )
    ]


def get_apriltag_nodes(context, *_, **__):
    use_apriltag = LaunchConfiguration("use_apriltag").perform(context)
    if use_apriltag != "true":
        return []

    try:
        apriltag_share = get_package_share_directory("apriltag_detector")
    except Exception:
        print("[bringup] apriltag_detector package not found. Skipping AprilTag detector launch.")
        return []

    drone_ns = _normalize_namespace(LaunchConfiguration("drone_namespace").perform(context))
    multi_drone_count = int(LaunchConfiguration('multi_drone_count').perform(context))
    multi_drone_prefix = LaunchConfiguration('multi_drone_namespace_prefix').perform(context)
    drone_namespaces = [drone_ns]
    if multi_drone_count > 1:
        drone_namespaces = [_namespace_from_prefix(multi_drone_prefix, i + 1) for i in range(multi_drone_count)]

    camera_ns_arg = LaunchConfiguration("apriltag_camera").perform(context)
    image_topic = LaunchConfiguration("apriltag_image").perform(context)
    tags_topic = LaunchConfiguration("apriltag_tags").perform(context)
    detector_type = LaunchConfiguration("apriltag_type").perform(context)
    bridge_topic = LaunchConfiguration("apriltag_bridge_topic").perform(context)
    use_standalone_detector = LaunchConfiguration("apriltag_use_standalone_detector").perform(context)
    if use_standalone_detector != 'true' and len(drone_namespaces) > 1:
        actions = [
            LogInfo(msg='[bringup] multi_drone_count>1 with apriltag_use_standalone_detector=false is not supported. Enable standalone detector.')
        ]
        return actions
    bridge_use_target_id = LaunchConfiguration("apriltag_bridge_use_target_id").perform(context)
    bridge_target_id = LaunchConfiguration("apriltag_bridge_target_id").perform(context)
    pkg_prefix = get_package_prefix('sjtu_drone_bringup')
    bridge_exe = os.path.join(pkg_prefix, 'lib', 'sjtu_drone_bringup', 'apriltag_state_bridge')
    if not os.path.isfile(bridge_exe):
        # Backward-compatible fallback for older installs that used bin/.
        bridge_exe = os.path.join(pkg_prefix, 'bin', 'apriltag_state_bridge')

    multi_mode = len(drone_namespaces) > 1
    actions = []
    for idx, ns in enumerate(drone_namespaces, start=1):
        camera_ns = _resolve_multi_ns_topic(camera_ns_arg, ns, f'{ns}/bottom', multi_mode)
        bridge_topic_ns = _resolve_multi_ns_topic(bridge_topic, ns, f'{ns}/landing_tag_state', multi_mode)
        tags_full_topic = f'{camera_ns}/{tags_topic}'
        image_full_topic = f'{camera_ns}/{image_topic}'
        state_topic = f'{ns}/state'

        actions.append(
            LogInfo(msg=f'[bringup] Apriltag[{idx}] ns={ns}, camera={camera_ns}, image={image_full_topic}, tags={tags_full_topic}, bridge={bridge_topic_ns}, standalone={use_standalone_detector}, use_target_id={bridge_use_target_id}, target_id={bridge_target_id}')
        )

        if use_standalone_detector == 'true':
            actions.append(
                Node(
                    package='apriltag_detector',
                    executable='apriltag_detector_node',
                    name=f'apriltag_detector_node_{idx:02d}',
                    output='screen',
                    parameters=[
                        {
                            'type': detector_type,
                        }
                    ],
                    remappings=[
                        ('image', image_full_topic),
                        ('tags', tags_full_topic),
                    ],
                    condition=IfCondition(LaunchConfiguration("use_apriltag")),
                )
            )
        else:
            actions.append(
                IncludeLaunchDescription(
                    PythonLaunchDescriptionSource(
                        os.path.join(apriltag_share, "launch", "detect.launch.py")
                    ),
                    launch_arguments={
                        "camera": camera_ns,
                        "image": image_topic,
                        "tags": tags_topic,
                        "type": detector_type,
                    }.items(),
                    condition=IfCondition(LaunchConfiguration("use_apriltag")),
                )
            )

        if os.path.exists(bridge_exe):
            actions.append(
                ExecuteProcess(
                    cmd=[
                        bridge_exe,
                        '--ros-args',
                        '-p', f'input_topic:={tags_full_topic}',
                        '-p', f'output_topic:={bridge_topic_ns}',
                        '-p', f'output_image_topic:={bridge_topic_ns}_image',
                        '-p', f'image_topic:={image_full_topic}',
                        '-p', f'state_topic:={state_topic}',
                        '-p', f'target_id:={bridge_target_id}',
                        '-p', f'use_target_id:={bridge_use_target_id}',
                        '-p', 'publish_annotated_image:=true',
                        '-p', 'monitor_log_period_sec:=2.0',
                    ],
                    output='screen',
                    condition=IfCondition(LaunchConfiguration("use_apriltag")),
                )
            )
        else:
            print(f"[bringup] apriltag_state_bridge executable not found at {bridge_exe}. Skipping bridge node.")

    return actions


def generate_launch_description():
    sjtu_drone_bringup_path = get_package_share_directory('sjtu_drone_bringup')

    rviz_path = os.path.join(
        sjtu_drone_bringup_path, "rviz", "rviz.rviz"
    )

    yaml_file_path = os.path.join(
        get_package_share_directory('sjtu_drone_bringup'),
        'config', 'drone.yaml'
    )

    model_ns = "/drone"

    with open(yaml_file_path, 'r') as f:
        yaml_dict = yaml.load(f, Loader=yaml.FullLoader)
        model_ns = _normalize_namespace(yaml_dict["namespace"])

    return LaunchDescription([
        DeclareLaunchArgument(
            "controller",
            default_value="keyboard",
            description="Type of controller: keyboard (default) or joystick",
        ),

        DeclareLaunchArgument(
            "drone_namespace",
            default_value=model_ns,
            description="Drone ROS namespace (e.g. /drone, /drone_w01)",
        ),

        DeclareLaunchArgument(
            'multi_drone_count',
            default_value='1',
            description='Number of drones to spawn in a single Gazebo world',
        ),

        DeclareLaunchArgument(
            'multi_drone_spacing_m',
            default_value='3.0',
            description='Spacing between spawned drones (m)',
        ),

        DeclareLaunchArgument(
            'multi_drone_namespace_prefix',
            default_value='drone_w',
            description='Namespace prefix used when spawning multiple drones',
        ),

        DeclareLaunchArgument(
            'multi_drone_spawn_tags',
            default_value='true',
            choices=['true', 'false'],
            description='Spawn one landing tag per drone in Gazebo',
        ),

        DeclareLaunchArgument(
            'multi_drone_use_world_tag_as_first',
            default_value='true',
            choices=['true', 'false'],
            description='Treat world built-in tag as the first drone tag',
        ),

        DeclareLaunchArgument(
            "use_apriltag",
            default_value="true",
            choices=["true", "false"],
            description="Whether to start apriltag_detector for landing zone tag tracking",
        ),

        DeclareLaunchArgument(
            "apriltag_camera",
            default_value="",
            description="Camera namespace for apriltag detector",
        ),

        DeclareLaunchArgument(
            "apriltag_image",
            default_value="image_raw",
            description="Image topic name under camera namespace",
        ),

        DeclareLaunchArgument(
            "apriltag_tags",
            default_value="tags",
            description="Output detections topic name under camera namespace",
        ),

        DeclareLaunchArgument(
            "apriltag_type",
            default_value="umich",
            choices=["umich", "mit"],
            description="Apriltag detector backend type",
        ),

        DeclareLaunchArgument(
            "apriltag_bridge_topic",
            default_value="",
            description="Bridge topic to publish tag state as Float32MultiArray",
        ),

        DeclareLaunchArgument(
            "apriltag_bridge_use_target_id",
            default_value="false",
            choices=["true", "false"],
            description="Whether apriltag_state_bridge filters by target_id",
        ),

        DeclareLaunchArgument(
            "apriltag_bridge_target_id",
            default_value="0",
            description="Target tag id used by apriltag_state_bridge when filtering is enabled",
        ),

        DeclareLaunchArgument(
            "apriltag_use_standalone_detector",
            default_value="true",
            choices=["true", "false"],
            description="Use apriltag_detector_node directly instead of detect.launch composable container",
        ),

        DeclareLaunchArgument(
            "takeoff_hover_height",
            default_value="0.8",
            description="Target altitude increase (m) after takeoff",
        ),

        DeclareLaunchArgument(
            "takeoff_vertical_speed",
            default_value="0.2",
            description="Vertical climb command used during takeoff",
        ),

        DeclareLaunchArgument(
            'fixed_frame',
            default_value='',
            description='If provided, sets the fixed frame in RViz.'
        ),

        DeclareLaunchArgument(
            'use_rviz',
            default_value='true',
            choices=['true', 'false'],
            description='Whether to launch RViz2',
        ),

        DeclareLaunchArgument(
            'use_teleop',
            default_value='false',
            choices=['true', 'false'],
            description='Whether to launch joystick and teleop nodes',
        ),

        DeclareLaunchArgument(
            'use_gui',
            default_value='true',
            choices=['true', 'false'],
            description='Whether to launch Gazebo with GUI',
        ),

        DeclareLaunchArgument(
            'pre_kill_gazebo',
            default_value='false',
            choices=['true', 'false'],
            description='Whether to kill existing gzserver/gzclient before launch',
        ),

        OpaqueFunction(
            function=rviz_node_generator,
            kwargs={'rviz_path': rviz_path},
        ),


        IncludeLaunchDescription(
            PythonLaunchDescriptionSource(
                os.path.join(sjtu_drone_bringup_path, 'launch', 'sjtu_drone_gazebo.launch.py')
            ),
            launch_arguments={
                'drone_namespace': LaunchConfiguration('drone_namespace'),
                'multi_drone_count': LaunchConfiguration('multi_drone_count'),
                'multi_drone_spacing_m': LaunchConfiguration('multi_drone_spacing_m'),
                'multi_drone_namespace_prefix': LaunchConfiguration('multi_drone_namespace_prefix'),
                'multi_drone_spawn_tags': LaunchConfiguration('multi_drone_spawn_tags'),
                'multi_drone_use_world_tag_as_first': LaunchConfiguration('multi_drone_use_world_tag_as_first'),
                'takeoff_hover_height': LaunchConfiguration('takeoff_hover_height'),
                'takeoff_vertical_speed': LaunchConfiguration('takeoff_vertical_speed'),
                'use_gui': LaunchConfiguration('use_gui'),
                'pre_kill_gazebo': LaunchConfiguration('pre_kill_gazebo'),
            }.items(),
        ),

        Node(
            package='joy',
            executable='joy_node',
            name='joy',
            namespace=LaunchConfiguration('drone_namespace'),
            output='screen',
            condition=IfCondition(LaunchConfiguration('use_teleop')),
        ),

        OpaqueFunction(
            function=get_teleop_controller,
            condition=IfCondition(LaunchConfiguration('use_teleop')),
        ),

        OpaqueFunction(
            function=get_apriltag_nodes,
        ),

    ])
