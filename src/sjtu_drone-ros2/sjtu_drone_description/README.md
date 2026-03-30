# sjtu_drone_description

드론 모델, world, Gazebo plugin을 제공하는 패키지입니다.

마지막 업데이트: 2026-03-30

## 디렉터리 구성

- `include/sjtu_drone_description`: plugin 헤더
- `src`: `plugin_drone`, `wind_plugin`, PID 구현
- `models/sjtu_drone`: SDF/mesh 모델
- `urdf`: xacro/urdf
- `worlds`: `landingPad.world`, `playground.world`
- `scripts/wind_tuner.py`: wind 파라미터 스윕 도구

## 빌드

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
colcon build --packages-select sjtu_drone_description
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

## Wind plugin 인터페이스

- `/wind_command` (`std_msgs/msg/Float32MultiArray`): `[speed_mps, direction_deg]`
- `/wind_condition` (`std_msgs/msg/Float32MultiArray`): 현재 풍 상태
- `/set_wind` (`sjtu_drone_interfaces/srv/SetWind`): 서비스 기반 제어

테스트:

```bash
ros2 topic pub /wind_command std_msgs/msg/Float32MultiArray "data: [4.0, 45.0]" -1
ros2 topic echo /wind_condition --once
```

## 런치 오버라이드 예시

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
	world:=/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/sjtu_drone_description/worlds/playground.world \
	takeoff_hover_height:=2.0 \
	takeoff_vertical_speed:=0.8
```
