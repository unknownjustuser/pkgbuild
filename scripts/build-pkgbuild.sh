#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

packages_dir="/home/cirrusci/pkgbuild/packages"

build_pkgbuild() {
  find "$packages_dir" -maxdepth 1 -type d | parallel -j0 --line-buffer '(cd "{}" && paru --noconfirm --needed --build "{}")'
}

# Main script
main() {
  build_pkgbuild
}

main "$@"
