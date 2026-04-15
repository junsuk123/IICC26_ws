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
    echo "[AUTOSIM-BRIDGE] No session found under $MATLAB_DIR/parallel_runs"
    exit 0
  fi
  SESSION_ROOT="$latest_session"
else
  if [[ -f "$SESSION_ARG" && "$(basename "$SESSION_ARG")" == "bridges.tsv" ]]; then
    SESSION_ROOT="$(dirname "$SESSION_ARG")"
  else
    SESSION_ROOT="$SESSION_ARG"
  fi
fi

if [[ "$(basename "$SESSION_ROOT")" == "bridge" ]]; then
  BRIDGE_ROOT="$SESSION_ROOT"
else
  BRIDGE_ROOT="$SESSION_ROOT/bridge"
fi

BRIDGE_TABLE="$BRIDGE_ROOT/bridges.tsv"
if [[ ! -f "$BRIDGE_TABLE" ]]; then
  echo "[AUTOSIM-BRIDGE] No bridge table found: $BRIDGE_TABLE"
  exit 0
fi

stopped=0
while IFS=$'\t' read -r pid worker_id from_domain to_domain config_file log_file; do
  if [[ "$pid" == "pid" || -z "$pid" ]]; then
    continue
  fi
  if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
    continue
  fi

  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    sleep 0.1
    if kill -0 "$pid" 2>/dev/null; then
      kill -9 "$pid" 2>/dev/null || true
    fi
    echo "[AUTOSIM-BRIDGE] Stopped bridge pid=$pid worker=$worker_id from=$from_domain to=$to_domain"
    stopped=$((stopped + 1))
  fi
done < "$BRIDGE_TABLE"

MONITOR_TABLE="$BRIDGE_ROOT/monitor.tsv"
if [[ -f "$MONITOR_TABLE" ]]; then
  while IFS=$'\t' read -r pid kind worker_id target log_file; do
    if [[ "$pid" == "pid" || -z "$pid" ]]; then
      continue
    fi
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
      continue
    fi

    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      sleep 0.1
      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null || true
      fi
      echo "[AUTOSIM-BRIDGE] Stopped monitor pid=$pid kind=$kind worker=$worker_id target=$target"
      stopped=$((stopped + 1))
    fi
  done < "$MONITOR_TABLE"
fi

echo "[AUTOSIM-BRIDGE] stop complete: $stopped process(es)."
