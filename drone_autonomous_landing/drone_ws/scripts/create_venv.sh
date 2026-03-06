#!/bin/bash
set -euo pipefail
# Create a workspace-local venv at .venv (idempotent) and install minimal packaging deps.
WS_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_DIR="$WS_ROOT/.venv"
if [ -d "$VENV_DIR" ]; then
  echo ".venv already exists at $VENV_DIR"
  exit 0
fi

echo "Creating venv at $VENV_DIR"
python3 -m venv "$VENV_DIR"
echo "Upgrading pip/setuptools/wheel in venv"
"$VENV_DIR/bin/pip" install --upgrade pip setuptools wheel tomli
echo "Created venv and installed pip packaging tools. To use it: source $VENV_DIR/bin/activate"
