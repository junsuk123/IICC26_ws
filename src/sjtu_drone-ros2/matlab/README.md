# MATLAB Landing Decision Node

This folder contains MATLAB code for wind generation and ontology-based landing decisions integrated with ROS2/Gazebo.

## Files

- `landing_decision_matlab.m`
	- Main decision node.
	- Publishes `/landing_decision` (`std_msgs/String`: `land`, `caution`, `wait`).
	- Uses wind state, drone pose, and AprilTag-based landing-zone stability.
- `startWindPublisher.m`
	- Wind generator/publisher entrypoint.
	- Composes steady wind + Dryden-like turbulence + wind shear + gust.
	- Supports continuous `/wind_command` publish and optional `/set_wind` service path.
- `wind_publisher_matlab.m`
	- Source implementation for `startWindPublisher` logic.

## Decision Inputs

- Wind: `/wind_condition` (`std_msgs/Float32MultiArray`)
- Pose: `/drone/gt_pose` (`geometry_msgs/Pose`)
- Tag detections (preferred): `/drone/bottom/tags` (`apriltag_msgs/msg/AprilTagDetectionArray`)
- Tag bridge fallback (no MATLAB custom msg required): `/landing_tag_state` (`std_msgs/Float32MultiArray`)

`landing_decision_matlab.m` includes landing-zone stability using:
- tag center offset in image frame
- center jitter (pixel RMS)
- tag area jitter (`std(area)/mean(area)`)
- detection quality (`decision_margin`)
- combined stability score

## Prerequisites

- MATLAB with ROS2 support (`ros2node`, `ros2subscriber`, `ros2publisher`, `receive`, `send`).
- Running ROS2/Gazebo bringup.

## Recommended Run Sequence

1. Build and source:

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --symlink-install
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

2. Launch simulation with AprilTag detector + bridge:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
	use_apriltag:=true \
	apriltag_camera:=/drone/bottom \
	apriltag_image:=image_raw \
	apriltag_tags:=tags \
	apriltag_type:=umich \
	apriltag_bridge_topic:=/landing_tag_state
```

3. Run MATLAB script:

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/landing_decision_matlab.m')
```

## Notes

- If MATLAB cannot resolve `apriltag_msgs` custom type, the script automatically falls back to `/landing_tag_state` bridge topic.
- Wind command example:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [5.0, 90.0]" -1
```
