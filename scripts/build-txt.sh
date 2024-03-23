#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail
# Get the directory path of the script
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Set the path to the packages directory
packages_dir="$script_dir/../packages"

txt() {
  while IFS= read -r line; do
    paru -Sy --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$line"
  done <"$packages_dir"/*.txt
  # paru -Sy --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$(cat "$packages_dir"/pkg.txt)"
}

# Main script
main() {
  txt
}

main "$@"
