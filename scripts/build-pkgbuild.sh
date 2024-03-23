#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

packages_dir="/home/cirrusci/pkgbuild/packages"

build_pkgbuild() {
  for dir in "$packages_dir"/*; do
    if [[ -d "$dir" ]]; then
      (cd "$dir" && paru --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast --build "$dir")
    fi
  done
}

# Main script
main() {
  build_pkgbuild
}

main "$@"
