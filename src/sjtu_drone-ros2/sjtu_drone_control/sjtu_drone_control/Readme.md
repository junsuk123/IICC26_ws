# sjtu_drone_control

수동/스크립트 드론 제어 노드를 제공합니다.

마지막 업데이트: 2026-03-30

## 주요 모듈

- `open_loop_control.py`
- `drone_position_control.py`
- `teleop.py`
- `teleop_joystick.py`
- `drone_utils/drone_object.py`
- `drone_utils/controllers.py`

## 실행 예시

Open-loop:

```bash
ros2 run sjtu_drone_control open_loop_control --task <square|triangle|forward|backward|left|right|up|down> --distance <float> --number <int>
```

Position control:

```bash
ros2 run sjtu_drone_control drone_position_control
```

Keyboard teleop:

```bash
ros2 run sjtu_drone_control teleop
```

Joystick teleop:

```bash
ros2 run sjtu_drone_control teleop_joystick
```

## bringup 연동

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py controller:=keyboard
```

헤드리스 환경 권장 옵션:

- `use_gui:=false`
- `use_rviz:=false`

## 멀티 드론 제어 메모

멀티 드론 모드에서는 네임스페이스별로 제어해야 합니다 (`/drone_w01`, `/drone_w02`, ...).

```bash
for ns in /drone_w01 /drone_w02 /drone_w03 /drone_w04; do
  ros2 topic pub ${ns}/takeoff std_msgs/msg/Empty {} --once
done
```
