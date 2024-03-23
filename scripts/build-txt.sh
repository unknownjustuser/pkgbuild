#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

packages_dir="/home/cirrusci/pkgbuild/packages"

txt() {
  cat "$packages_dir"/*.txt | parallel -j0 --line-buffer 'paru -Sy --noprogressbar --noconfirm --quiet --needed {}'
}

# Main script
main() {
  txt
}

main "$@"
