# MATLAB Integration Guide

This folder contains MATLAB nodes for:

- dynamic wind generation and ROS2 publishing
- landing decision inference using wind + drone state + AprilTag stability
- startup takeoff sequencing and XY PID hold using AprilTag predicted center

## Files

- `landing_decision_matlab.m`
  - main decision node
  - publishes `/landing_decision` (`std_msgs/String`: `land`, `caution`, `wait`)
- `startWindPublisher.m`
  - public entrypoint to start dynamic wind publishing loop
- `wind_publisher_matlab.m`
  - same publisher implementation is mirrored here (function name is also `startWindPublisher`)
- `auto_landing_pipeline_matlab.m`
  - full automation entrypoint: launch-repeat-stop-label-train-infer
  - repeatedly runs Gazebo via `ros2 launch`, stops with `pkill`/`gz` kill between scenarios
  - labels landing success/failure from threshold rules on ROS topics
  - saves dataset and timestamped model, then runs inference

## ROS Interfaces

### Inputs

- `/wind_condition` (`std_msgs/Float32MultiArray`)
- `/drone/gt_pose` (`geometry_msgs/Pose`)
- `/drone/bottom/tags` (`apriltag_msgs/msg/AprilTagDetectionArray`) if MATLAB custom type is available
- `/landing_tag_state` (`std_msgs/Float32MultiArray`) fallback bridge topic

### Outputs

- `/drone/takeoff` (`std_msgs/Empty`) startup takeoff trigger
- `/drone/cmd_vel` (`geometry_msgs/Twist`) XY hold commands
- `/landing_decision` (`std_msgs/String`)
- `/wind_command` (`std_msgs/Float32MultiArray`) when MATLAB wind publisher is enabled

## Wind Generation Algorithm

Implemented in `startWindPublisher` as a fixed-rate timer loop.

### Model composition

Total horizontal wind vector:

- `W = W_steady + W_dryden + W_gust`

with direction-dependent decomposition into x/y components.

### Components

1. Steady wind
- magnitude: `steady_speed`
- direction: `steady_dir` (deg)

2. Wind shear (power law)
- `U(z) = U_ref * (z / z_ref)^alpha`
- altitude `z` from pose topic when available

3. Dryden-like turbulence (time-domain approximation)
- first-order exponential filters on white noise for longitudinal/lateral components
- parameters:
  - `dryden.Lu`, `dryden.Lv`
  - `dryden.sigma_u`, `dryden.sigma_v`

4. Gust events
- Poisson-triggered burst events with exponential decay
- parameters:
  - `gust.prob`
  - `gust.amp`

### Publish paths

- service path (optional): `/set_wind`
- topic path (continuous): `/wind_command`

Recommended robust mode for this workspace:

- `use_set_wind_service = false`
- continuous topic publish to `/wind_command`

## Landing Decision Algorithm

Implemented in `landing_decision_matlab.m`.

### Pipeline Overview (Current)

Decision is now structured as:

1. sensor collection
2. ontology state construction
3. ontology reasoning (symbolic abstraction)
4. AI feature vector generation
5. AI landing decision (`land`/`caution`/`wait`)
6. decision publish to `/landing_decision`

### Stage A: sensor and tag feature extraction

Tag feature extraction:

- target id selection (`tag_target_id`, default 0)
- center in pixels (`centre` or `center`, fallback from corners)
- polygon area from tag corners
- detection quality from `decision_margin`

Stability features:

- center jitter: RMS of frame-to-frame center displacement (px)
- area jitter ratio: `std(area)/mean(area)`
- margin mean
- center offset in normalized image coordinates

Composite stability score in `[0,1]` combines:

- center jitter term
- area jitter term
- margin quality term

### Stage B: ontology state construction

`buildOntologyState(...)` creates ontology-style state with classes/entities/relations.

Ontology classes/entities:

- `WindCondition`
- `DroneState`
- `TagObservation`
- `LandingContext`

Ontology relations (triples):

- `DroneState isAffectedByWind WindCondition`
- `DroneState isAlignedWithLandingMarker TagObservation`
- `TagObservation hasVisualUncertainty LandingContext`
- `LandingContext isSafeForLanding DroneState`
- `LandingContext requiresCaution WindCondition`

### Stage C: ontology reasoning (semantic abstraction)

`ontologyReasoning(...)` derives symbolic interpretation used before AI inference:

- `wind_risk = low | medium | high`
- `alignment_state = aligned | misaligned`
- `visual_state = stable | unstable`
- `landing_context = safe | caution | unsafe`

### Stage D: AI feature generation

`buildAIFeatureVector(...)` converts numeric + semantic states into a model input vector.

Feature layout:

`[wind_speed, wind_dir_norm, roll_abs, pitch_abs, tag_u, tag_v, jitter, area_ratio, margin, stability_score, wind_risk_enc, alignment_enc, visual_enc]`

### Stage E: AI decision inference

`aiLandingDecision(...)` performs softmax-based 3-class inference:

- classes: `land`, `caution`, `wait`
- current script includes a lightweight placeholder model (`aiModel.W`, `aiModel.b`)
- replace these parameters with trained model weights for experiments

Rule-based fallback is reduced to low-confidence backup only:

- fallback function: `decision_tree_fallback(...)`
- enabled by: `cfg.enable_rule_fallback`
- trigger threshold: `cfg.ai_confidence_min`

### Stage F: control/experiment separation

Takeoff/hover/xy-hold state machine is still present for experiments, but runs separately from the ontology+AI decision path.

### Stage G: tag loss continuity

- on valid detection, node caches latest tag state (`id`, center, area, margin)
- on short dropout, cached state is reused for `tag_hold_timeout_sec`

This reduces abrupt semantic/AI input discontinuity during temporary detector loss.

### Startup + XY hold control

- phase flow: `wait_ready -> takeoff -> hover_settle -> xy_hold`
- startup prefers `/drone/state` and falls back to altitude-based inference when state is stale
- XY hold uses predicted tag center (`u_pred`, `v_pred`) and falls back to current center when needed
- control output publishes to `/drone/cmd_vel` with zero z/yaw command

Current startup gate for experiments:

- phase flow is now `wait_ready -> pre_takeoff_stabilize -> takeoff -> hover_settle -> xy_hold`
- in `pre_takeoff_stabilize`, node continuously publishes zero wind command (`/wind_command = [0, 0]`)
- takeoff is allowed only after zero-wind settle time and continuous tag-center hold are satisfied


## Fallback for MATLAB custom message limitations

If MATLAB cannot create subscriber for `apriltag_msgs`, the script automatically falls back to `/landing_tag_state` (`std_msgs/Float32MultiArray`) and continues full stability inference.

Bridge vector format:

- `[detected, tag_id, center_x_px, center_y_px, area_px2, margin, num_tags]`

## Run Procedure

## Quick Start (MATLAB Only)

If your goal is full automation (launch -> repeat scenarios -> auto labeling -> train -> infer), use this minimal flow.

1. In terminal, source ROS2 + workspace:

```bash
cd /home/j/INCSL/IICC26_ws
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

2. Start MATLAB from the same shell (recommended), then run:

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/auto_landing_pipeline_matlab.m')
```

3. Output files are generated automatically:

- dataset: `matlab/data/landing_dataset_*.mat`, `matlab/data/landing_dataset_*.csv`
- inference result: `matlab/data/landing_inference_*.csv`
- trained model: `matlab/models/landing_model_*.mat`

4. To force a specific model for inference:

```bash
export LANDING_MODEL_FILE=/abs/path/to/landing_model_YYYYMMDD_HHMMSS.mat
```

5. Main tuning points in `auto_landing_pipeline_matlab.m`:

- `cfg.scenario.*` (scenario count/duration)
- `cfg.thresholds.*` (success/failure criteria)
- `cfg.launch.command` (launch arguments)

1. Build and source workspace:

```bash
cd /home/j/INCSL/IICC26_ws
colcon build --symlink-install
source /opt/ros/humble/setup.bash
source /home/j/INCSL/IICC26_ws/install/setup.bash
```

2. Launch simulation + AprilTag + bridge:

```bash
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

3. Run MATLAB:

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/landing_decision_matlab.m')
```

4. Optional quick interface checks:

```bash
ros2 topic echo /landing_decision
ros2 topic echo /landing_tag_state --once
ros2 topic echo /wind_condition --once
```

## Full Automation (One MATLAB Run)

If you want MATLAB to run everything automatically (launch, scenario loop, cleanup, labeling, training, inference):

```matlab
run('/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/auto_landing_pipeline_matlab.m')
```

What this script does:

- starts `ros2 launch sjtu_drone_bringup sjtu_drone_bringup.launch.py` for each scenario
- stops previous scenario processes (`pkill ...`, `gzserver/gzclient`) before next run
- publishes `/drone/takeoff` in each scenario startup phase
- runs XY PID control via `/drone/cmd_vel` during hover/hold phase
- displays live visualization (altitude, tag error, PID command, control phase)
- subscribes to:
  - `/drone/state`
  - `/drone/gt_pose`
  - `/drone/gt_vel`
  - `/drone/bumper_states`
  - `/landing_tag_state`
  - `/wind_condition`
- publishes:
  - `/wind_command` (scenario wind profile)
  - `/drone/land` (landing trigger)
- computes threshold-based landing labels (`success` / `failed`)
- accumulates and saves dataset (`.mat` + `.csv`)
- trains and saves model with datetime filename:
  - `matlab/models/landing_model_YYYYMMDD_HHMMSS.mat`
- runs inference with latest model by default
- on user interrupt (`Ctrl+C`), still saves partial dataset/model artifacts
- writes rolling checkpoints after each scenario to reduce data loss

Interrupt-safe persistence outputs:

- checkpoint dataset (latest overwrite):
  - `matlab/data/landing_dataset_checkpoint_latest.mat`
  - `matlab/data/landing_dataset_checkpoint_latest.csv`
- finalized run dataset (status suffix):
  - `matlab/data/landing_dataset_YYYYMMDD_HHMMSS_completed.csv`
  - `matlab/data/landing_dataset_YYYYMMDD_HHMMSS_interrupted.csv`
  - `matlab/data/landing_dataset_YYYYMMDD_HHMMSS_failed.csv`
- model save behavior:
  - if enough labeled rows exist, normal trained model is saved
  - if rows are insufficient or training fails, a placeholder model is still saved:
    - `matlab/models/landing_model_YYYYMMDD_HHMMSS_placeholder.mat`

### Labeling Thresholds

Thresholds are centralized in `defaultConfig()` of `auto_landing_pipeline_matlab.m` under `cfg.thresholds`.

Key conditions include:

- landed state check (`/drone/state == 0`)
- final altitude limit
- final speed limit
- final roll/pitch limits
- final tag-center error limit (`/landing_tag_state` based)
- final window stability (`std(z)`, `std(vz)`)
- bumper contact count limit

Adjust these values to tune strictness for stable/unstable labels.

### Model Selection for Inference

- default: latest model file in `matlab/models`
- specific model: set `cfg.inference.model_file` to a full `.mat` path
- runtime override without editing file:
  - `export LANDING_MODEL_FILE=/abs/path/to/landing_model_YYYYMMDD_HHMMSS.mat`

Example:

```matlab
cfg.inference.model_file = '/home/j/INCSL/IICC26_ws/src/sjtu_drone-ros2/matlab/models/landing_model_20260309_000000.mat';
```

Output artifacts:

- `matlab/data/landing_dataset_*.mat`
- `matlab/data/landing_dataset_*.csv`
- `matlab/data/landing_inference_*.csv`
- `matlab/models/landing_model_*.mat`

## Practical Tuning Tips

- If decision is too conservative:
  - increase `tag_center_tolerance`
  - increase `tag_jitter_warn_px`
  - decrease `tag_stability_score_warn`
- If false landing approvals occur:
  - increase `tag_margin_warn`
  - increase `tag_min_area_px2`
  - decrease `tag_area_jitter_warn_ratio`

## Key Runtime Parameters (Current Defaults)

- `params.tag_predict_timeout_sec = 0.6`
- `params.tag_hold_last_state = true`
- `params.tag_hold_timeout_sec = 0.6`
- `params.pre_takeoff_zero_wind_enabled = true`
- `params.pre_takeoff_zero_wind_settle_sec = 2.0`
- `params.pre_takeoff_require_tag_centered = false`
- `params.pre_takeoff_tag_center_tolerance = 0.03`
- `params.pre_takeoff_tag_center_hold_sec = 1.0`
- `params.xy_pid_kp = 1.2`
- `params.xy_control_center_deadband = 0.005`
- `params.flying_altitude_threshold = 0.20`
- `params.state_stale_timeout_sec = 1.0`
- `cfg.wind_start_delay_after_hover_sec = 5.0`
- `params.wind_start_require_tag_centered = true`
- `params.wind_start_tag_center_hold_sec = 1.0`
- `cfg.enable_rule_fallback = true`
- `cfg.ai_confidence_min = 0.42`

## PID Direction and Visualization

`landing_decision_matlab.m` live plot includes a dedicated panel:

- Tag-Drone alignment (`u,v` normalized frame)
- current tag point and predicted tag point
- alignment vector (predicted tag -> center)
- command vector (PID intent) from current `cmd_x`,`cmd_y`
- phase/state text (`control_phase`, `drone_state`, `align_err`)

If drone moves away from the tag, tune sign mapping:

- `params.xy_map_sign_x_from_v`
- `params.xy_map_sign_y_from_u`

Flip only the axis that is reversed (set `1.0` <-> `-1.0`).
