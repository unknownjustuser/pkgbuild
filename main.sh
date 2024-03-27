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
  echo "Available commands: setup, build-txt, build-pkgbuild, push, srcinfo"
  exit 1
fi

# Execute the corresponding script based on the command
for cmd in "$@"; do
  case "$cmd" in
  setup)
    chmod +x "$SCRIPTS_DIR"/setup.sh
    ./"$SCRIPTS_DIR/setup.sh"
    ;;
  build-txt)
    chmod +x "$SCRIPTS_DIR"/build-txt.sh
    ./"$SCRIPTS_DIR/build-txt.sh"
    ;;
  build-pkgbuild)
    chmod +x "$SCRIPTS_DIR"/build-pkgbuild.sh
    ./"$SCRIPTS_DIR/build-pkgbuild.sh"
    ;;
  push)
    chmod +x "$SCRIPTS_DIR"/push.sh
    ./"$SCRIPTS_DIR/push.sh"
    ;;
  srcinfo)
    chmod +x "$SCRIPTS_DIR"/srcinfo.sh
    ./"$SCRIPTS_DIR/srcinfo.sh"
    ;;
  *)
    echo "Invalid command. Available commands: setup, build-txt, build-pkgbuild, push, srcinfo"
    exit 1
    ;;
  esac
done
