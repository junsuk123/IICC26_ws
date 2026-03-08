# sjtu_drone_control

Control nodes for manual and scripted drone motion.

## Main modules

- `drone_utils/drone_object.py`
  - helper class for basic movement primitives
- `open_loop_control.py`
  - scripted open-loop tasks
- `drone_position_control.py`
  - position-control logic using plugin/PID dynamics
- `teleop.py`
  - keyboard teleop
- `teleop_joystick.py`
  - joystick teleop

## Executables

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

## Bringup notes

Typical launch:

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py controller:=keyboard
```

Takeoff behavior can be tuned from launch:

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py \
  controller:=keyboard \
  takeoff_hover_height:=2.0 \
  takeoff_vertical_speed:=0.8
```

For non-GUI/headless environments, prefer:

- `controller:=joystick`
- `use_rviz:=false`
- `use_gui:=false`

Teleop note:

- `s` key sends zero `cmd_vel` (velocity hover command), not an explicit altitude hold setpoint.
