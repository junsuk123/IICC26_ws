#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MATLAB_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SESSION_ARG="${1:-}"

sanitize_arg() {
  local x="$1"
  x="${x//$'\r'/}"
  x="${x//$'\n'/}"
  x="${x#\"}"
  x="${x%\"}"
  printf '%s' "$x"
}

SESSION_ARG="$(sanitize_arg "$SESSION_ARG")"

if [[ -z "$SESSION_ARG" ]]; then
  latest_session="$(find "$MATLAB_DIR/parallel_runs" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -n 1 || true)"
  if [[ -z "$latest_session" ]]; then
    echo "[AUTOSIM-TAIL] No session found under $MATLAB_DIR/parallel_runs"
    exit 1
  fi
  SESSION_ROOT="$latest_session"
else
  if [[ -f "$SESSION_ARG" && "$(basename "$SESSION_ARG")" == "workers.tsv" ]]; then
    SESSION_ROOT="$(dirname "$SESSION_ARG")"
  else
    SESSION_ROOT="$SESSION_ARG"
  fi
fi

PID_TABLE="$SESSION_ROOT/workers.tsv"
if [[ ! -f "$PID_TABLE" ]]; then
  echo "[AUTOSIM-TAIL] workers.tsv not found: $PID_TABLE"
  exit 1
fi

echo "[AUTOSIM-TAIL] Session root: $SESSION_ROOT"
echo "[AUTOSIM-TAIL] Press Ctrl+C to stop."

pids=()
cleanup() {
  for p in "${pids[@]:-}"; do
    if kill -0 "$p" 2>/dev/null; then
      kill "$p" 2>/dev/null || true
    fi
  done
}
trap cleanup EXIT INT TERM

while IFS=$'\t' read -r pid worker_id domain_id gazebo_port log_file; do
  if [[ "$pid" == "pid" || -z "$worker_id" ]]; then
    continue
  fi

  if [[ -z "$log_file" ]]; then
    continue
  fi

  if [[ ! -f "$log_file" ]]; then
    touch "$log_file"
  fi

  prefix="[W${worker_id}|D${domain_id}|G${gazebo_port}]"
  stdbuf -oL tail -n 0 -F "$log_file" 2>/dev/null | sed -u "s/^/${prefix} /" &
  pids+=("$!")
done < "$PID_TABLE"

if [[ ${#pids[@]} -eq 0 ]]; then
  echo "[AUTOSIM-TAIL] No worker log stream found in: $PID_TABLE"
  exit 1
fi

wait
