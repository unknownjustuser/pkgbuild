#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkgbuild_repo="$HOME/pkgbuild"
packages_dir="$pkgbuild_repo/packages"

for dir in "$packages_dir"/*/; do
  cd "$dir"
  makepkg --printsrcinfo >.SRCINFO
  cd -
done
