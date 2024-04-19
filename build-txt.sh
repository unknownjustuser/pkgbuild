#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkg build for *.txt file "cirrus CI".
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail
pkgbuild_repo="/src"

txt() {
  while IFS= read -r line; do
    paru -Sy --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$line"
  done <"$pkgbuild_repo"/*.txt
}

# Main script
main() {
  txt
}

main
