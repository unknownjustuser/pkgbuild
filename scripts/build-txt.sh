#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail
pkgbuild_repo="/home/cirrusci/pkgbuild"
packages_dir="$pkgbuild_repo/packages"

txt() {
  while IFS= read -r line; do
    paru -Sy --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$line"
  done <"$packages_dir"/*.txt
}

# Main script
main() {
  txt
}

main "$@"
