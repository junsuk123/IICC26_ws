1. **drone_utils/drone_object.py**: Defines `DroneObject` utility methods for takeoff/land and movement primitives.

2. **open_loop_control.py**: Implements open-loop commands (no feedback correction). Run with:

   ```bash
   ros2 run sjtu_drone_control open_loop_control --task <'square'|'triangle'|'forward'|'backward'|'left'|'right'|'up'|'down'> --distance <float> --number <int>
   ```


3. **drone_position_control.py**: Position control based on Gazebo plugin/PID. Run with:

   ```bash
   ros2 run sjtu_drone_control drone_position_control
   ```

4. **teleop.py / teleop_joystick.py**: Keyboard and joystick teleop nodes used by bringup.

## Typical usage with bringup

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py controller:=keyboard
```

For headless environments without xterm, use joystick controller or adjust launch settings.