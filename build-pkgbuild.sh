#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkgbuild_repo="$HOME/packages"

removeconf() {
  source ./PKGBUILD

  local all_conf=("${conflicts[@]}")
  all_conf=("${all_conf[@]##*/}")

  local conflicts_installed=()
  for dep in "${all_conf[@]}"; do
    if pacman -Qs "$dep" >/dev/null 2>&1; then
      conflicts_installed+=("$dep")
    fi
  done

  if [[ ${#conflicts_installed[@]} -gt 0 ]]; then
    echo "Removing conflicting packages: ${conflicts_installed[*]}"
    paru -Rnsc --noconfirm --noprogressbar "${conflicts_installed[@]}"
  fi
}

depsinstall() {
  source ./PKGBUILD

  local all_deps=("${depends[@]}" "${makedepends[@]}")
  all_deps=("${all_deps[@]##*/}")

  if [[ ${#all_deps[@]} -gt 0 ]]; then
    echo "Installing dep packages"
    paru -S --noconfirm --needed --noprogressbar "${all_deps[@]}"
  fi
}

removedeps() {
  source ./PKGBUILD

  local all_deps=("${depends[@]}" "${makedepends[@]}")
  all_deps=("${all_deps[@]##*/}")

  if [[ ${#all_deps[@]} -gt 0 ]]; then
    echo "Removing dep packages"
    paru -Rnsc --noconfirm --noprogressbar "${all_deps[@]}"
  fi
}

build_pkgbuild() {
  for dir in *; do
    pushd "$dir" || exit
    removeconf
    depsinstall
    aur build --cleanbuild --sign --no-confirm --temp --rmdeps "$dir"
    # removedeps
    popd || exit
  done
}

# Main script
main() {
  cd "$pkgbuild_repo"
  build_pkgbuild
}

main
