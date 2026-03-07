# MATLAB Landing Decision Node

This folder contains a MATLAB script to run a simple ontology-based landing decision node that integrates with the existing ROS2/Gazebo bringup.

Files
- `landing_decision_matlab.m` — main script. Subscribes to `/wind_condition` and a drone pose topic and publishes `/landing_decision` (`std_msgs/String`) with values `land`, `caution`, or `wait`.

Prerequisites
- MATLAB with ROS2 support (ros2node, ros2subscriber, ros2publisher, send/receive APIs).
- ROS2 environment and the `sjtu_drone_bringup` launch working (Gazebo + drone model).
- Ensure you have sourced your ROS2 workspace in the shell if you plan to let MATLAB spawn a system launch (or start the launch manually before running the MATLAB script).

How to run
1. Build and source the workspace (once):

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --packages-select sjtu_drone_description
source install/setup.bash
```

2. Start bringup launch (either in shell):

```bash
ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py
```

or set `cfg.use_launch = true` and `cfg.launchCMD` inside `landing_decision_matlab.m` to let MATLAB start it.

3. Run the MATLAB script (in MATLAB):

```matlab
run('.../src/sjtu_drone-ros2/matlab/landing_decision_matlab.m')
```

Notes and extension ideas
- The current script implements a small Decision Tree and a toy Bayesian score. You can extend it to use a learned policy (RL), a real knowledge graph (RDF/OWL) interface, or a more complex Bayesian Network implementation.
- To test dynamic wind changes, publish to `/wind_command` (the Gazebo wind plugin in this repository supports runtime updates). The MATLAB node reads `/wind_condition` which the plugin publishes.
- For integration testing, extend the script to subscribe to `/drone/odom` or other state topics to compute velocity and attitude rates.

Feedback
If you'd like, I can:
- Add a service-based control (`/set_wind`) to the plugin and adapt the MATLAB script to call the service.
- Replace the string decision message with a custom message containing confidence and ontology fields.
- Make the MATLAB script record experiments (CSV) and produce evaluation plots like success rates vs wind conditions.
