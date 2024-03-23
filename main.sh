#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

# Get the directory of the main script
SCRIPTS_DIR="scripts"

# Check if a command is provided
if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <command>"
  echo "Available commands: setup, gensum, build-txt, build-pkgbuild, push, check, srcinfo"
  exit 1
fi

# Make scripts executable
chmod +x "$SCRIPTS_DIR"/*.sh

# Execute the scripts in parallel
parallel --no-notice -j0 --line-buffer "./{} {}" ::: "$SCRIPTS_DIR"/{setup,gensum,build-txt,build-pkgbuild,push,check,srcinfo}.sh ::: "$@"
