# sjtu_drone (IICC26 Workspace)

This repository contains a ROS2 + Gazebo Classic drone simulation based on `sjtu_drone`, extended for IICC26 with:

- runtime wind control (`/wind_command`, `/set_wind`, `/wind_condition`)
- MATLAB landing decision integration
- MATLAB-driven startup (`takeoff`) + XY PID tag-centering hold
- AprilTag-based landing-zone observability and stability logic
- AprilTag bridge topic (`/landing_tag_state`) for MATLAB environments without custom message support
- short tag-dropout continuity using last valid tag state hold (prevents control/decision discontinuity)

## Requirements

- Ubuntu 22.04
- ROS2 Humble
- Gazebo 11 (Classic)

## Workspace Build

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --symlink-install
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

If `--symlink-install` fails with a stale build folder (e.g. symlink conflict under `build/sjtu_drone_interfaces` or `build/sjtu_drone_description`), remove only the failing package build folder and rebuild:

```bash
rm -rf /home/j/INCSL/IICC26_ws/build/sjtu_drone_interfaces
rm -rf /home/j/INCSL/IICC26_ws/build/sjtu_drone_description
colcon build --symlink-install
```

## Run (Recommended Headless)

This mode avoids common GUI issues (`rviz2`/`xterm` in restricted environments):

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

Takeoff tuning launch arguments:

- `takeoff_hover_height` (m): altitude increase target after takeoff
- `takeoff_vertical_speed` (controller command): climb aggressiveness during takeoff phase

If you edit launch/xacro/plugin files under `src/`, rebuild affected packages before relaunch so install-space files are updated.

## Wind Model Integration

### Topics and service

- `/wind_command` (`std_msgs/msg/Float32MultiArray`): `[speed_mps, direction_deg]`
- `/wind_condition` (`std_msgs/msg/Float32MultiArray`): plugin wind state output
- `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`): optional service control path

### Quick wind test

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [5.0, 90.0]" -1
ros2 topic echo /wind_condition --once
```

## AprilTag Pipeline

### Detector output

- `/drone/bottom/tags` (`apriltag_msgs/msg/AprilTagDetectionArray`)

### MATLAB-safe bridge output

- `/landing_tag_state` (`std_msgs/msg/Float32MultiArray`)
- data format:
  - `data[0]` detected (0/1)
  - `data[1]` tag id
  - `data[2]` center x (px)
  - `data[3]` center y (px)
  - `data[4]` area (px^2)
  - `data[5]` decision margin
  - `data[6]` number of detections

MATLAB landing node keeps the last valid tag state for a short timeout when detections are momentarily lost, so tag position does not break abruptly in control/decision loops.

## MATLAB Integration

See `matlab/README.md` for full algorithm details, topic contracts, and tuning parameters.

Quick note: MATLAB node now publishes control during startup/hold:

- `/drone/takeoff` (`std_msgs/Empty`)
- `/drone/cmd_vel` (`geometry_msgs/Twist`)
- `/landing_decision` (`std_msgs/String`)

Recent control behavior updates:

- fallback flight-state inference from altitude when `/drone/state` is stale
- XY hold uses predicted center first, then current center as fallback
- optional delayed wind start after hover settle (reduces startup transients)

## Known Environment Issues

- `rviz2` may fail with `GLIBC_PRIVATE` symbol errors in mixed host/snap library environments.
  - workaround: `use_rviz:=false`
- `xterm` teleop may fail in non-GUI sessions.
  - workaround: `controller:=joystick` or headless run profile above
