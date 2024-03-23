#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

packages_dir="/home/cirrusci/pkgbuild/packages"

txt() {
  # while IFS= read -r line; do
  #   paru -Sy --noprogressbar --noconfirm --quiet --needed "$line"
  # done <"$packages_dir"/*.txt
  paru -Syw --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$(cat "$packages_dir"/pkg.txt)"
}

# Main script
main() {
  txt
}

main "$@"
