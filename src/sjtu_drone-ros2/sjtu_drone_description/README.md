# sjtu_drone_description

This package contains the drone model, world files, and Gazebo plugins used by the workspace.

## Structure

- `models/` Gazebo model resources
- `urdf/` drone xacro and urdf
- `src/` C++ plugin implementations
- `include/` plugin headers
- `worlds/` simulation world files

## Worlds

Included world files:

- `playground.world`
- `landingPad.world`

`sjtu_drone_bringup` currently defaults to `landingPad.world`.

To launch a different world:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
	world:=/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/sjtu_drone_description/worlds/playground.world
```

If the source world file is changed, rebuild this package so the install-space launch path is updated:

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --packages-select sjtu_drone_description
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## Wind Plugin

The world plugin `libwind_plugin.so` is used to apply wind forces to models.

Interfaces:

- `/wind_command` (`std_msgs/msg/Float32MultiArray`): command input `[speed_mps, direction_deg]`
- `/wind_condition` (`std_msgs/msg/Float32MultiArray`): plugin output state
- `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`): optional service control path

Current default plugin parameters in `worlds/landingPad.world`:

- `wind_speed: 0.0`
- `wind_direction: 0`
- `area: 0.1`
- `force_coeff: 1.0`
- `publish_rate_hz: 10.0`

Quick check:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [4.0, 45.0]" -1
ros2 topic echo /wind_condition --once
```

## Takeoff Hover Configuration

Drone plugin now supports configurable takeoff target behavior:

- `takeoffHoverHeight` (YAML/xacro/plugin): altitude increase target in meters
- `takeoffVerticalSpeed` (YAML/xacro/plugin): climb command during takeoff phase

Default values are defined in:

- `sjtu_drone_bringup/config/drone.yaml`

Current defaults in code/yaml:

- `takeoffHoverHeight: 1.0`
- `takeoffVerticalSpeed: 1.0`

Launch-time override:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  takeoff_hover_height:=2.0 \
  takeoff_vertical_speed:=0.8
```

## AprilTag + MATLAB Integration Context

When bringup is launched with AprilTag enabled:

- detector output topic: `/drone/bottom/tags`
- bridge output topic: `/landing_tag_state`

`/landing_tag_state` exists for MATLAB environments that cannot import `apriltag_msgs` custom message definitions.
MATLAB landing logic can optionally hold the last valid bridge/tag state for short dropouts to keep tag-center control continuous.

## Generate URDF/SDF

Generate URDF:

```bash
ros2 run xacro xacro -o ./urdf/sjtu_drone.urdf ./urdf/sjtu_drone.urdf.xacro \
	params_path:="$(ros2 pkg prefix sjtu_drone_bringup)/share/sjtu_drone_bringup/config/drone.yaml" \
	takeoff_hover_height:=2.0 \
	takeoff_vertical_speed:=0.8
```

Generate SDF:

```bash
gz sdf -p ./urdf/sjtu_drone.urdf > ./models/sjtu_drone/model.sdf
```
