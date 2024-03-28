#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail
pkgbuild_repo="$HOME/packages"

txt() {
  while IFS= read -r line; do
    paru -Sy --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast "$line"
  done <"$pkgbuild_repo"/*.txt
}

# Main script
main() {
  txt
}

main "$@"
