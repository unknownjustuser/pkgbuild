#!/bin/bash
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Automate pkgbuild on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkgbuild_repo="packages"
installed_aur_deps="installed_aur_deps.txt"

removeconf() {
  source ./PKGBUILD

  local all_conf=("${conflicts[@]}")
  all_conf=("${all_conf[@]##*/}")

  if [[ ${#all_conf[@]} -gt 0 ]]; then
    echo "Removing conflicting packages: ${all_conf[*]}"
    paru -Rnsc --noconfirm --noprogressbar "${all_conf[@]}"
  fi
}

depsinstall() {
  source ./PKGBUILD

  local all_deps=("${depends[@]}" "${makedepends[@]}")
  all_deps=("${all_deps[@]##*/}")

  if [[ ${#all_deps[@]} -gt 0 ]]; then
    echo "Installing AUR dep packages: ${all_deps[*]}"
    paru -S --noconfirm --needed --noprogressbar "${all_deps[@]}"
    printf "%s\n" "${all_deps[@]}" >>"$installed_aur_deps"
  fi
}

removedeps() {
  if [[ -f "$installed_aur_deps" ]]; then
    while IFS= read -r dep; do
      if paru -Qs "$dep" >/dev/null 2>&1; then
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
