# Wind Tuner

`wind_tuner.py` runs parameter sweeps for wind plugin settings and records `/wind_condition`.

## Prerequisites

```bash
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

Ensure `sjtu_drone_description` is built and `libwind_plugin.so` is installed.

## Example

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

## What it records

- `/wind_condition` time series
- one output folder per parameter combination
- gzserver logs for each run

## Relation to landing pipeline

- MATLAB landing node reads `/wind_condition`.
- Startup takeoff target can be tuned via bringup launch args `takeoff_hover_height` and `takeoff_vertical_speed`.
- AprilTag landing observability runs in parallel from bringup.
- Bridge topic `/landing_tag_state` supports MATLAB fallback when custom tag messages are unavailable.
- MATLAB landing node may hold last valid tag state for a short timeout during tag dropouts, so evaluate both raw detector stability and hold-time behavior when tuning.

## Extensions

For full landing-performance tuning, extend the script to include:

- pose drift metrics
- touchdown success criteria
- ranking/scoring across wind parameter sets
