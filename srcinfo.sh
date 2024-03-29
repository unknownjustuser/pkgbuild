#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

packages_dir="packages"

for dir in "$packages_dir"/*/; do
  cd "$dir"
  makepkg --printsrcinfo >.SRCINFO
  cd -
done
