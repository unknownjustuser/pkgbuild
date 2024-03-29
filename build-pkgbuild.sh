#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkgbuild_repo="$HOME/packages"
installed_aur_deps="$pkgbuild_repo/installed_aur_deps.txt"

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

  local aur_deps=()
  for dep in "${all_deps[@]}"; do
    if ! pacman -Qs "$dep" >/dev/null 2>&1; then
      aur_deps+=("$dep")
    fi
  done

  if [[ ${#aur_deps[@]} -gt 0 ]]; then
    echo "Installing AUR dep packages: ${aur_deps[*]}"
    paru -S --noconfirm --needed --noprogressbar "${aur_deps[@]}"
    printf "%s\n" "${aur_deps[@]}" >>"$installed_aur_deps"
  fi
}

removedeps() {
  if [[ -f "$installed_aur_deps" ]]; then
    while IFS= read -r dep; do
      if pacman -Qs "$dep" >/dev/null 2>&1; then
        echo "Removing dep package: $dep"
        paru -Rnsc --noconfirm --noprogressbar "$dep"
      fi
    done <"$installed_aur_deps"
    rm "$installed_aur_deps"
  fi
}

build_pkgbuild() {
  for dir in *; do
    pushd "$dir" || exit
    removeconf
    depsinstall
    aur build --cleanbuild --syncdeps --sign --no-confirm --temp --rmdeps "$dir"
    removedeps
    popd || exit
  done
}

# Main script
main() {
  cd "$pkgbuild_repo"
  build_pkgbuild
}

main
