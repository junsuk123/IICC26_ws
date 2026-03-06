#!/bin/bash
# use strict mode but relax unset-var check while sourcing ROS/colcon setup
set -eo pipefail
# Wrapper to run ros2 launch with a clean Python environment.
# If workspace .venv exists, prefer it; otherwise use /usr/bin.
WS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [ -d "$WS_ROOT/.venv" ]; then
	export PATH="$WS_ROOT/.venv/bin:$PATH"
else
	export PATH="/usr/bin:$PATH"
fi
unset PYTHONPATH || true
export PYTHONNOUSERSITE=1
# ensure Gazebo can find built plugins and models from the workspace install
export GAZEBO_PLUGIN_PATH="$WS_ROOT/install/drone_description/lib:${GAZEBO_PLUGIN_PATH:-}"
export GAZEBO_MODEL_PATH="$WS_ROOT/install/drone_description/share/drone_description/models:${GAZEBO_MODEL_PATH:-}"
export LD_LIBRARY_PATH="$WS_ROOT/install/drone_description/lib:${LD_LIBRARY_PATH:-}"
# Remove known problematic IsaacSim/Omniverse entries from environment paths so
# runtime Python doesn't pick up incompatible prebundled numpy/extensions.
clean_colon_list() {
	# remove any path segments that contain the substring 'isaacsim' or 'omni'
	local in="$1"
	local out
	out=$(printf "%s" "$in" | awk -v RS=":" -v ORS=":" '!/isaacsim/ && !/omni/ {print}' | sed 's/:$//')
	printf "%s" "$out"
}
export PATH="$(clean_colon_list "$PATH")"
export LD_LIBRARY_PATH="$(clean_colon_list "${LD_LIBRARY_PATH:-}")"
export PYTHONPATH="$(clean_colon_list "${PYTHONPATH:-}")"
# setup.bash may access variables that aren't set; temporarily disable -u while sourcing
set +u
source "$WS_ROOT/install/setup.bash"
# Run the launch inside a clean subshell so child processes inherit a minimal, controlled environment.
# By default run the local windy world (development-friendly). If you want the original
# ROS2 package launch, pass any argument (or set FIRST_ARG to 'ros') to keep previous behavior.
unset PYTHONPATH || true
export PYTHONNOUSERSITE=1

# If no args provided (or user explicitly requests 'windy'), start gzserver/gzclient
# using the source world and workspace model/plugin dirs so development copies are used.
if [ -z "$1" ] || [ "$1" = "windy" ]; then
	WORLD_PATH="$WS_ROOT/src/drone_description/worlds/AI_Center3_windy.world"
	export GAZEBO_MODEL_PATH="$WS_ROOT/src/drone_description/models:${GAZEBO_MODEL_PATH:-}"
	export LD_LIBRARY_PATH="$WS_ROOT/src/drone_description/plugins:${LD_LIBRARY_PATH:-}"
	CMD="gzserver -v \"$WORLD_PATH\""
	# Start gzserver in the background and then gzclient in the foreground so the
	# script behaves similarly to ros2 launch (both processes show on screen).
	CMD_FULL="bash -lc \"$CMD & gzclient\""
	env -u PYTHONPATH PYTHONNOUSERSITE=1 PATH=/usr/bin:$PATH bash -lc "$CMD_FULL"
else
	# Fallback to original ROS2 launch invocation (keeps previous behavior)
	CMD="source \"$WS_ROOT/install/setup.bash\" && ros2 launch drone gazebo_drone.launch.py $*"
	env -u PYTHONPATH PYTHONNOUSERSITE=1 PATH=/usr/bin:$PATH bash -lc "$CMD"
fi
