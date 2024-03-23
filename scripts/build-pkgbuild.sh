#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

# Get the directory path of the script
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

packages_dir="$script_dir/../packages"

removeconf() {
  for dir in "$packages_dir"/*/; do
    cd "$dir" || exit
    source ./PKGBUILD

    local all_conf=("${conflicts[@]}")
    all_conf=("${all_conf[@]##*/}") # Remove potential leading paths

    local conflicts_installed=()
    for dep in "${all_conf[@]}"; do
      if pacman -Qs "$dep" >/dev/null 2>&1; then
        conflicts_installed+=("$dep")
      fi
    done

    if [[ ${#conflicts_installed[@]} -gt 0 ]]; then
      echo "Removing conflicting packages: ${conflicts_installed[*]}"
      sudo paru -Rnsc --noconfirm --sudoloop "${conflicts_installed[@]}"
    fi

    cd - || exit
  done
}

build_pkgbuild() {
  for dir in "$packages_dir"/*; do
    if [[ -d "$dir" ]]; then
      (cd "$dir" && removeconf && paru --nokeepsrc --noprogressbar --noconfirm --quiet --needed --failfast --build "$dir")
    fi
  done
}

# Main script
main() {
  build_pkgbuild
}

main "$@"
