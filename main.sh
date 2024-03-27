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
  echo "Available commands: setup, gensum, build-txt, build-pkgbuild, push, srcinfo"
  exit 1
fi

# Execute the corresponding script based on the command
for cmd in "$@"; do
  case "$cmd" in
  setup)
    chmod +x "$SCRIPTS_DIR"/setup.sh
    ./"$SCRIPTS_DIR/setup.sh" &>/dev/null
    ;;
  gensum)
    chmod +x "$SCRIPTS_DIR"/gensum.sh
    ./"$SCRIPTS_DIR"/gensum.sh &>/dev/null
    ;;
  build-txt)
    chmod +x "$SCRIPTS_DIR"/build-txt.sh
    ./"$SCRIPTS_DIR/build-txt.sh" &>/dev/null
    ;;
  build-pkgbuild)
    chmod +x "$SCRIPTS_DIR"/build-pkgbuild.sh
    ./"$SCRIPTS_DIR/build-pkgbuild.sh" &>/dev/null
    ;;
  push)
    chmod +x "$SCRIPTS_DIR"/push.sh
    ./"$SCRIPTS_DIR/push.sh" &>/dev/null
    ;;
  srcinfo)
    chmod +x "$SCRIPTS_DIR"/srcinfo.sh
    ./"$SCRIPTS_DIR/srcinfo.sh" &>/dev/null
    ;;
  *)
    echo "Invalid command. Available commands: setup, gensum, build-txt, build-pkgbuild, push, srcinfo"
    exit 1
    ;;
  esac
done
