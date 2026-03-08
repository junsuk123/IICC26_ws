# sjtu_drone (IICC26 Workspace)

This repository contains a ROS2 + Gazebo Classic drone simulation based on `sjtu_drone`, extended for IICC26 with:

- runtime wind control (`/wind_command`, `/set_wind`, `/wind_condition`)
- MATLAB landing decision integration
- MATLAB-driven startup (`takeoff`) + XY PID tag-centering hold
- AprilTag-based landing-zone observability and stability logic
- AprilTag bridge topic (`/landing_tag_state`) for MATLAB environments without custom message support
- short tag-dropout continuity using last valid tag state hold

## Requirements

- Ubuntu 22.04
- ROS2 Humble
- Gazebo 11 (Classic)

## Repository Packages

- `sjtu_drone_bringup`: main launch files, RViz config, bridge executable
- `sjtu_drone_description`: URDF/xacro, world files, Gazebo plugins
- `sjtu_drone_control`: keyboard/joystick teleop and control helpers
- `sjtu_drone_interfaces`: custom service definitions (`SetWind`)
- `matlab/`: MATLAB landing and wind scripts

## Workspace Build

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --symlink-install
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

If you edit files under `src/`, rebuild affected packages before relaunch so install-space launch resources are updated.

## Launch (Recommended Headless)

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash

ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  use_gui:=false \
  use_rviz:=false \
  controller:=joystick \
  takeoff_hover_height:=2.0 \
  takeoff_vertical_speed:=0.8 \
  use_apriltag:=true \
  apriltag_camera:=/drone/bottom \
  apriltag_image:=image_raw \
  apriltag_tags:=tags \
  apriltag_type:=umich \
  apriltag_bridge_topic:=/landing_tag_state
```

Important launch defaults from code:

- `controller:=keyboard`
- `use_apriltag:=true`
- `use_rviz:=true`
- `takeoff_hover_height:=1.0`
- `takeoff_vertical_speed:=1.0`

## Wind Interfaces

- `/wind_command` (`std_msgs/msg/Float32MultiArray`): `[speed_mps, direction_deg]`
- `/wind_condition` (`std_msgs/msg/Float32MultiArray`): plugin output `[speed_mps, direction_deg]`
- `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`): request `{speed, direction}`

Quick test:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [5.0, 90.0]" -1
ros2 topic echo /wind_condition --once
```

## AprilTag Pipeline

- detector output: `/drone/bottom/tags` (`apriltag_msgs/msg/AprilTagDetectionArray`)
- bridge output: `/landing_tag_state` (`std_msgs/msg/Float32MultiArray`)

Bridge vector format:

- `[detected, tag_id, center_x_px, center_y_px, area_px2, margin, num_tags]`

## MATLAB Integration

See `matlab/README.md` for full decision logic and parameter tuning.

MATLAB landing node publishes:

- `/drone/takeoff` (`std_msgs/Empty`)
- `/drone/cmd_vel` (`geometry_msgs/Twist`)
- `/landing_decision` (`std_msgs/String`: `land`/`caution`/`wait`)

## Known Environment Issues

- `rviz2` may fail with `GLIBC_PRIVATE` symbol errors in mixed host/snap library environments.
  Workaround: `use_rviz:=false`
- `xterm` teleop may fail in non-GUI sessions.
  Workaround: `controller:=joystick`
