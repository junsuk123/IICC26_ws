# Wind Tuner

This folder contains `wind_tuner.py`, a small experiment runner to sweep wind plugin
parameters and record `/wind_condition` messages from the running Gazebo world.

Prerequisites
- Source your ROS2 workspace environment first (so `rclpy` and messages are available):

```bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

- Ensure `gzserver` is available on PATH and the plugin library (`libwind_plugin.so`) is built and installed in the package (run `colcon build --packages-select sjtu_drone_description`).

Quick run example

```bash
python3 scripts/wind_tuner.py \
  --world src/sjtu_drone_description/worlds/playground.world \
  --area 0.1 0.2 0.5 \
  --coeff 0.5 1.0 2.0 \
  --speed 2.0 5.0 \
  --dir 0 90 180 \
  --duration 15 \
  --out /tmp/wind_tuning
```

What it does
- For each combination of area/coeff/speed/dir, it writes a temporary world (copy of the provided template) with a `wind_plugin` block inserted.
- Launches `gzserver` with that world and records messages published on `/wind_condition` for the requested duration.
- Saves a CSV of recorded wind messages and gzserver logs per experiment in `--out`.

Notes / next steps
- This script records only the `/wind_condition` topic. For a full tuning loop that measures actual landing performance you can extend it to:
  - subscribe to model pose topics (e.g. Gazebo model state topics) or use a ROS2 node that monitors landing success
  - implement automated success/failure criteria (position drift, touchdown event, etc.)
  - run in headless CI by using `gzserver` as done here and collect logs

If you want, I can extend this runner to also track drone pose and compute landing success metrics, and then produce a summary report (CSV/plots) ranking parameter sets by performance.