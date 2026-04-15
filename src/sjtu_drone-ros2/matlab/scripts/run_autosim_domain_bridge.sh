#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATLAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_ARG="${1:-}"
OBSERVE_DOMAIN="${OBSERVE_DOMAIN:-90}"
AUTOSIM_ROS_LOCALHOST_ONLY="${AUTOSIM_ROS_LOCALHOST_ONLY:-0}"
AUTOSIM_BRIDGE_LAUNCH_RVIZ="${AUTOSIM_BRIDGE_LAUNCH_RVIZ:-true}"

# Setup ROS environment silently
. /opt/ros/humble/setup.bash 2>/dev/null || true
WS_DIR="${MATLAB_DIR%/src/sjtu_drone-ros2/matlab}"
[ -f "$WS_DIR/install/setup.bash" ] && . "$WS_DIR/install/setup.bash" 2>/dev/null || true

# Resolve session root
if [[ -z "$SESSION_ARG" ]]; then
  SESSION_ROOT="$(find "$MATLAB_DIR/parallel_runs" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1)"
  [[ -z "$SESSION_ROOT" ]] && { echo "[AUTOSIM-BRIDGE] No session found"; exit 1; }
elif [[ -f "$SESSION_ARG" && "$(basename "$SESSION_ARG")" == "workers.tsv" ]]; then
  SESSION_ROOT="$(dirname "$SESSION_ARG")"
else
  SESSION_ROOT="$SESSION_ARG"
fi

# Verify setup
! command -v ros2 >/dev/null 2>&1 && { echo "[AUTOSIM-BRIDGE] ros2 command not found"; exit 1; }
! ros2 pkg prefix domain_bridge >/dev/null 2>&1 && { echo "[AUTOSIM-BRIDGE] domain_bridge not found"; exit 1; }
[[ ! -f "$SESSION_ROOT/workers.tsv" ]] && { echo "[AUTOSIM-BRIDGE] workers.tsv not found: $SESSION_ROOT"; exit 1; }

# Setup directories
BRIDGE_ROOT="$SESSION_ROOT/bridge"
CONFIG_DIR="$BRIDGE_ROOT/configs"
LOG_DIR="$BRIDGE_ROOT/logs"
mkdir -p "$CONFIG_DIR" "$LOG_DIR"
MONITOR_TABLE="$BRIDGE_ROOT/monitor.tsv"
printf "pid\tkind\tworker_id\ttarget\tlog_file\n" > "$MONITOR_TABLE"

echo "[AUTOSIM-BRIDGE] Session: $SESSION_ROOT"
echo "[AUTOSIM-BRIDGE] Observe domain: $OBSERVE_DOMAIN"

rviz_binary="$(command -v rviz2 2>/dev/null || true)"
drone_urdf_file=""
if drone_desc_prefix="$(ros2 pkg prefix sjtu_drone_description 2>/dev/null || true)" && [[ -n "$drone_desc_prefix" ]] && [[ -f "$drone_desc_prefix/share/sjtu_drone_description/urdf/sjtu_drone.urdf" ]]; then
  drone_urdf_file="$drone_desc_prefix/share/sjtu_drone_description/urdf/sjtu_drone.urdf"
elif [[ -f "$MATLAB_DIR/../sjtu_drone_description/urdf/sjtu_drone.urdf" ]]; then
  drone_urdf_file="$MATLAB_DIR/../sjtu_drone_description/urdf/sjtu_drone.urdf"
fi

autosim_write_monitor_rviz_config() {
  local cfg_path="$1"
  local urdf_path="$2"
  shift 2
  local worker_ids=("$@")

  cat > "$cfg_path" <<EOF
Panels:
  - Class: rviz_common/Displays
    Help Height: 70
    Name: Displays
    Property Tree Widget:
      Expanded:
        - /Global Options1
        - /Status1
        - /TF1
      Splitter Ratio: 0.5
    Tree Height: 70
  - Class: rviz_common/Selection
    Name: Selection
  - Class: rviz_common/Tool Properties
    Expanded:
      - /2D Goal Pose1
      - /Publish Point1
    Name: Tool Properties
    Splitter Ratio: 0.5886790156364441
  - Class: rviz_common/Views
    Expanded:
      - /Current View1
    Name: Views
    Splitter Ratio: 0.5
  - Class: rviz_common/Time
    Experimental: false
    Name: Time
    SyncMode: 0
    SyncSource: ""
Visualization Manager:
  Class: ""
  Displays:
    - Alpha: 0.5
      Cell Size: 1
      Class: rviz_default_plugins/Grid
      Color: 160; 160; 164
      Enabled: true
      Line Style:
        Line Width: 0.029999999329447746
        Value: Lines
      Name: Grid
      Normal Cell Count: 0
      Offset:
        X: 0
        Y: 0
        Z: 0
      Plane: XY
      Plane Cell Count: 10
      Reference Frame: <Fixed Frame>
      Value: true
    - Class: rviz_default_plugins/TF
      Enabled: true
      Frame Timeout: 15
      Frames:
        All Enabled: true
      Marker Scale: 1
      Name: TF
      Show Arrows: true
      Show Axes: true
      Show Names: true
      Tree: {}
      Update Interval: 0
      Value: true
EOF

  for wid in "${worker_ids[@]}"; do
    wid2="$(printf '%02d' "$wid")"
    cat >> "$cfg_path" <<EOF
    - Alpha: 1
      Class: rviz_default_plugins/RobotModel
      Collision Enabled: false
      Description File: $urdf_path
      Description Source: File
      Enabled: true
      Links:
        All Links Enabled: true
      Name: RobotModel w${wid2}
      TF Prefix: drone_w${wid2}
      Update Interval: 0
      Value: true
    - Class: rviz_default_plugins/Image
      Enabled: true
      Max Value: 1
      Median window: 5
      Min Value: 0
      Name: AprilTag Annotated w${wid2}
      Normalize Range: true
      Topic:
        Depth: 5
        Durability Policy: Volatile
        History Policy: Keep Last
        Reliability Policy: Reliable
        Value: /observe/w${wid2}/landing_tag_state_image
      Value: true
    - Class: rviz_default_plugins/Marker
      Enabled: true
      Name: Landing Pad w${wid2}
      Namespaces:
        landing_pad: true
      Topic:
        Depth: 5
        Durability Policy: Volatile
        History Policy: Keep Last
        Reliability Policy: Reliable
        Value: /observe/w${wid2}/landing_pad_marker
      Value: true
EOF
  done

  cat >> "$cfg_path" <<'EOF'
  Enabled: true
  Global Options:
    Background Color: 48; 48; 48
    Fixed Frame: world
    Frame Rate: 30
  Name: root
  Tools:
    - Class: rviz_default_plugins/Interact
      Hide Inactive Objects: true
    - Class: rviz_default_plugins/MoveCamera
    - Class: rviz_default_plugins/Select
    - Class: rviz_default_plugins/FocusCamera
    - Class: rviz_default_plugins/Measure
      Line color: 128; 128; 0
    - Class: rviz_default_plugins/SetInitialPose
      Covariance x: 0.25
      Covariance y: 0.25
      Covariance yaw: 0.06853891909122467
      Topic:
        Depth: 5
        Durability Policy: Volatile
        History Policy: Keep Last
        Reliability Policy: Reliable
        Value: /initialpose
    - Class: rviz_default_plugins/SetGoal
      Topic:
        Depth: 5
        Durability Policy: Volatile
        History Policy: Keep Last
        Reliability Policy: Reliable
        Value: /goal_pose
    - Class: rviz_default_plugins/PublishPoint
      Single click: true
      Topic:
        Depth: 5
        Durability Policy: Volatile
        History Policy: Keep Last
        Reliability Policy: Reliable
        Value: /clicked_point
  Transformation:
    Current:
      Class: rviz_default_plugins/TF
  Value: true
  Views:
    Current:
      Class: rviz_default_plugins/Orbit
      Distance: 8
      Enable Stereo Rendering:
        Stereo Eye Separation: 0.05999999865889549
        Stereo Focal Distance: 1
        Swap Stereo Eyes: false
        Value: false
      Focal Point:
        X: 0
        Y: 0
        Z: 0.4
      Focal Shape Fixed Size: true
      Focal Shape Size: 0.05
      Invert Z Axis: false
      Name: Current View
      Near Clip Distance: 0.01
      Pitch: 0.25
      Target Frame: <Fixed Frame>
      Value: Orbit (rviz)
      Yaw: 3.0
    Saved:
      - Class: rviz_default_plugins/Orbit
        Distance: 10
        Enable Stereo Rendering:
          Stereo Eye Separation: 0.05999999865889549
          Stereo Focal Distance: 1
          Swap Stereo Eyes: false
          Value: false
        Focal Point:
          X: 0
          Y: 0
          Z: 0
        Focal Shape Fixed Size: true
        Focal Shape Size: 0.05
        Invert Z Axis: false
        Name: Orbit
        Near Clip Distance: 0.01
        Pitch: 0.41539835929870605
        Target Frame: <Fixed Frame>
        Value: Orbit (rviz)
        Yaw: 5.893581390380859
EOF
}

worker_ids=()
count=0
clock_bridged="false"
while IFS=$'\t' read -r pid wid domain_id port log; do
  [[ -z "$wid" ]] && continue
  if ! [[ "$wid" =~ ^[0-9]+$ ]]; then
    continue
  fi

  wid2="$(printf '%02d' "$wid")"
  cfg="$CONFIG_DIR/domain_bridge_w${wid2}.yaml"

  {
    echo "name: autosim_bridge_w${wid2}"
    echo "from_domain: ${domain_id}"
    echo "to_domain: ${OBSERVE_DOMAIN}"
    echo "topics:"
    if [[ "$clock_bridged" == "false" ]]; then
      cat <<EOF
  /clock:
    type: rosgraph_msgs/msg/Clock
    remap: /clock
EOF
      clock_bridged="true"
    fi
    cat <<EOF
  /tf:
    type: tf2_msgs/msg/TFMessage
    remap: /tf
  /tf_static:
    type: tf2_msgs/msg/TFMessage
    remap: /tf_static
  /drone_w${wid2}/state:
    type: std_msgs/msg/Int8
    remap: /observe/w${wid2}/state
  /drone_w${wid2}/gt_pose:
    type: geometry_msgs/msg/Pose
    remap: /observe/w${wid2}/gt_pose
  /drone_w${wid2}/imu:
    type: sensor_msgs/msg/Imu
    remap: /observe/w${wid2}/imu
  /drone_w${wid2}/landing_tag_state:
    type: std_msgs/msg/Float32MultiArray
    remap: /observe/w${wid2}/landing_tag_state
  /drone_w${wid2}/landing_tag_state_image:
    type: sensor_msgs/msg/Image
    remap: /observe/w${wid2}/landing_tag_state_image
  /wind_condition:
    type: std_msgs/msg/Float32MultiArray
    remap: /observe/w${wid2}/wind_condition
EOF
  } > "$cfg"

  log_file="$LOG_DIR/domain_bridge_w${wid2}.log"
  (export ROS_DOMAIN_ID="$OBSERVE_DOMAIN"; export ROS_LOCALHOST_ONLY="$AUTOSIM_ROS_LOCALHOST_ONLY"; ros2 run domain_bridge domain_bridge "$cfg") >"$log_file" 2>&1 &
  bridge_pid=$!
  printf "%s\tbridge\t%s\t%s\t%s\n" "$bridge_pid" "$wid" "$domain_id" "$log_file" >> "$MONITOR_TABLE"
  echo "[AUTOSIM-BRIDGE] Worker $wid bridge (domain $domain_id → $OBSERVE_DOMAIN)"

  worker_ids+=("$wid")
  count=$((count + 1))
done < <(tail -n +2 "$SESSION_ROOT/workers.tsv")

if [[ $count -eq 0 ]]; then
  echo "[AUTOSIM-BRIDGE] No workers found"
  exit 1
fi

echo "[AUTOSIM-BRIDGE] Started $count bridge(s)"

if [[ "$AUTOSIM_BRIDGE_LAUNCH_RVIZ" == "1" || "$AUTOSIM_BRIDGE_LAUNCH_RVIZ" == "true" || "$AUTOSIM_BRIDGE_LAUNCH_RVIZ" == "yes" ]]; then
  if [[ -n "$rviz_binary" && -n "$drone_urdf_file" ]]; then
    monitor_rviz_cfg="$CONFIG_DIR/autosim_monitor.rviz"
    autosim_write_monitor_rviz_config "$monitor_rviz_cfg" "$drone_urdf_file" "${worker_ids[@]}"

    rviz_log="$LOG_DIR/autosim_monitor_rviz.log"
    (export ROS_DOMAIN_ID="$OBSERVE_DOMAIN"; export ROS_LOCALHOST_ONLY="$AUTOSIM_ROS_LOCALHOST_ONLY"; "$rviz_binary" -d "$monitor_rviz_cfg" --ros-args -p use_sim_time:=true) >"$rviz_log" 2>&1 &
    rviz_pid=$!
    printf "%s\trviz\tall\t%s\t%s\n" "$rviz_pid" "$OBSERVE_DOMAIN" "$rviz_log" >> "$MONITOR_TABLE"
    echo "[AUTOSIM-BRIDGE] Monitor RViz started pid=$rviz_pid"

    for wid in "${worker_ids[@]}"; do
      wid2="$(printf '%02d' "$wid")"
      pad_topic="/observe/w${wid2}/landing_pad_marker"
      pad_frame="drone_w${wid2}/landing_pad"
      pad_log="$LOG_DIR/landing_pad_marker_w${wid2}.log"
      (export ROS_DOMAIN_ID="$OBSERVE_DOMAIN"; export ROS_LOCALHOST_ONLY="$AUTOSIM_ROS_LOCALHOST_ONLY"; ros2 run sjtu_drone_bringup landing_pad_marker_publisher --ros-args -p topic:="$pad_topic" -p frame_id:="$pad_frame") >"$pad_log" 2>&1 &
      pad_pid=$!
      printf "%s\tpad_marker\t%s\t%s\t%s\n" "$pad_pid" "$wid" "$pad_topic" "$pad_log" >> "$MONITOR_TABLE"
      echo "[AUTOSIM-BRIDGE] Pad marker started for worker $wid2"
    done
  else
    echo "[AUTOSIM-BRIDGE] Monitor RViz skipped: rviz2 or drone URDF not available"
  fi
fi
