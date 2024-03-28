#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkgbuild_repo="$HOME/packages"

removeconf() {
  for dir in "$pkgbuild_repo"/*/; do
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
      sudo paru -Rnsc --noconfirm --sudoloop --noprogressbar "${conflicts_installed[@]}"
    fi

    cd - || exit
  done
}

depsinstall() {
  for dir in "$pkgbuild_repo"/*/; do
    cd "$dir" || exit
    source ./PKGBUILD

    local all_deps=("${depends[@]}" "${makedepends[@]}")
    all_deps=("${all_deps[@]##*/}")

    if [[ ${#all_deps[@]} -gt 0 ]]; then
      echo "Installing dep packages: ${all_deps[*]}"
      sudo paru -S --noconfirm --needed --sudoloop --noprogressbar "${all_deps[@]}"
    fi

    cd - || exit
  done
}

build_pkgbuild() {
  for dir in "$pkgbuild_repo"/*; do
    if [[ -d "$dir" ]]; then
      (cd "$dir" && removeconf && depsinstall && aur build --cleanbuild --sign --no-confirm --temp "$dir")
    fi
  done
}

# Main script
main() {
  build_pkgbuild
}

main "$@"
