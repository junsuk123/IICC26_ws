#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATLAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_ARG="${1:-}"
OBSERVE_DOMAIN="${OBSERVE_DOMAIN:-90}"

# Setup ROS environment silently
. /opt/ros/humble/setup.bash 2>/dev/null || true
WS_DIR="${MATLAB_DIR%/src/sjtu_drone-ros2/matlab}"
[ -f "$WS_DIR/install/setup.bash" ] && . "$WS_DIR/install/setup.bash" 2>/dev/null || true

# Resolve session root
if [ -z "$SESSION_ARG" ]; then
  SESSION_ROOT="$(find "$MATLAB_DIR/parallel_runs" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1)"
  [ -z "$SESSION_ROOT" ] && { echo "[AUTOSIM-BRIDGE] No session found"; exit 1; }
elif [ -f "$SESSION_ARG" ] && [ "$(basename "$SESSION_ARG")" = "workers.tsv" ]; then
  SESSION_ROOT="$(dirname "$SESSION_ARG")"
else
  SESSION_ROOT="$SESSION_ARG"
fi

# Verify setup
! command -v ros2 >/dev/null 2>&1 && { echo "[AUTOSIM-BRIDGE] ros2 command not found"; exit 1; }
! ros2 pkg prefix domain_bridge >/dev/null 2>&1 && { echo "[AUTOSIM-BRIDGE] domain_bridge not found"; exit 1; }
[ ! -f "$SESSION_ROOT/workers.tsv" ] && { echo "[AUTOSIM-BRIDGE] workers.tsv not found: $SESSION_ROOT"; exit 1; }

# Setup directories
BRIDGE_ROOT="$SESSION_ROOT/bridge"
CONFIG_DIR="$BRIDGE_ROOT/configs"
LOG_DIR="$BRIDGE_ROOT/logs"
mkdir -p "$CONFIG_DIR" "$LOG_DIR"

echo "[AUTOSIM-BRIDGE] Session: $SESSION_ROOT"
echo "[AUTOSIM-BRIDGE] Observe domain: $OBSERVE_DOMAIN"

# Launch bridges
tail -n +2 "$SESSION_ROOT/workers.tsv" | { count=0; while IFS=$'\t' read -r pid wid domain_id port log; do
  [ -z "$wid" ] || ! echo "$wid" | grep -q "^[0-9]\+$" && continue
  
  wid2=$(printf '%02d' "$wid")
  cfg="$CONFIG_DIR/domain_bridge_w${wid2}.yaml"
  
  cat > "$cfg" <<EOF
name: autosim_bridge_w${wid2}
from_domain: ${domain_id}
to_domain: ${OBSERVE_DOMAIN}
topics:
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
  /wind_condition:
    type: std_msgs/msg/Float32MultiArray
    remap: /observe/w${wid2}/wind_condition
EOF

  log="$LOG_DIR/domain_bridge_w${wid2}.log"
  (export ROS_DOMAIN_ID=$OBSERVE_DOMAIN; ros2 run domain_bridge domain_bridge "$cfg") >"$log" 2>&1 &
  echo "[AUTOSIM-BRIDGE] Worker $wid bridge (domain $domain_id → $OBSERVE_DOMAIN)"
  count=$((count + 1))
done
[ $count -eq 0 ] && { echo "[AUTOSIM-BRIDGE] No workers found"; exit 1; }
echo "[AUTOSIM-BRIDGE] Started $count bridge(s)"
}
