#!/bin/bash
set -eo pipefail
# Wrapper to run colcon build with a clean Python environment.
# If a workspace venv (.venv) exists, prefer it; otherwise fall back to /usr/bin.
# Usage: ./scripts/build.sh [colcon args]
WS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Force use of system binaries for the build to ensure CMake/ament uses system python
export PATH="/usr/bin:$PATH"
unset PYTHONPATH || true
# Prevent loading user site-packages which can contain incompatible setuptools/numpy
export PYTHONNOUSERSITE=1
# Run colcon using the system python to avoid picking up unrelated Python installs
# but keep PYTHONNOUSERSITE and unset PYTHONPATH to prevent user-site contamination.
/usr/bin/python3 -m colcon build --symlink-install "$@"
