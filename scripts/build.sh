#!/usr/bin/env bash
# shellcheck disable=SC2035
# shellcheck disable=SC1091

# Script name: build.sh
# Description: Script for automating pkgbuild on "ci".
# Contributors: MikuX-Dev

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

# Default values
OUTPUT_DIR="$HOME/output"
AURBUILD="$HOME/aur-build"
PKGSTXT="$HOME/archfiery-pkgbuild/packages"
YAYCACHE="$HOME/.cache/yay"
LOCALPKG="$HOME/archfiery-pkgbuild/packages"

# Find the *.txt file in $PKGSTXT
TXT_FILE=$(find "$PKGSTXT" -maxdepth 1 -type f -name "*.txt" | head -n 1)

# Check if a *.txt file is found
if [ -z "$TXT_FILE" ]; then
  echo "Error: No *.txt file found in $HOME"
  exit 1
fi

un_comment_jmake() {
  sudo sed -i 's|^#MAKEFLAGS.*|MAKEFLAGS="-j$(nproc)"|g' /etc/makepkg.conf
  sudo sed -i 's|^#BUILDDIR.*|BUILDDIR=/tmp/makepkg|g' /etc/makepkg.conf
}

# Directories to be used within the script
declare -a dirs=(
  "$OUTPUT_DIR"
  "$AURBUILD"
  "$HOME/output-large"
  "$HOME/output-small"
)

# Function to create directories
create_directories() {
  mkdir -p "${dirs[@]}"
}

clone_pkg() {
  pushd "$AURBUILD"
  while IFS= read -r package; do
    git clone https://aur.archlinux.org/"$package"
  done <"$TXT_FILE"
  popd
}

# Function to check if a package is in the official repositories
is_in_repos() {
  pacman -Ss "$1" >/dev/null 2>&1
}

# Function to install AUR dependencies
install_aur_deps() {
  source ./PKGBUILD
  local all_deps=("${depends[@]}" "${makedepends[@]}")

  for dep in "${all_deps[@]}"; do
    if ! is_in_repos "$dep"; then
      echo "Installing AUR dependency: $dep"
      yay -Sy --needed --noconfirm --asdeps --sudoloop "$dep"
    else
      sudo pacman -Sy --needed --noconfirm --asdeps "$dep"
    fi
  done
}

iad() {
  clone_pkg

  for dir in "$AURBUILD"/*/; do
    pushd "$dir"
    install_aur_deps
    popd
  done
}

build_aur_packages() {
  for dir in "$AURBUILD"/*/; do
    pushd "$dir"
    makepkg --clean --needed --nodeps --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar
    popd
  done
}

build_local_packages() {
  for dir in "$LOCALPKG"/*/; do
    pushd "$dir"
    makepkg --clean --needed --nodeps --noconfirm --skippgpcheck --skipchecksums --skipinteg --noprogressbar
    popd
  done
}

copy_aur_deps() {
  for dir in "$YAYCACHE"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

copy_build_pkg() {
  for dir in "$AURBUILD"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

copy_build_local() {
  for dir in "$LOCALPKG"/*/; do
    cp -r "$dir"/*.pkg.tar.* "$OUTPUT_DIR"
  done
}

# Function to categorize packages based on size
categorize_packages() {
  local input_dir="$1"
  local large_output_dir="$HOME/output-large"
  local small_output_dir="$HOME/output-small"

  for pkg_file in "$input_dir"/*.pkg.tar.*; do
    local size
    size=$(du -m "$pkg_file" | cut -f1)
    if ((size > 100)); then
      mv -f "$pkg_file" "$large_output_dir"
    else
      mv -f "$pkg_file" "$small_output_dir"
    fi
  done
}

# Main execution flow
main() {
  create_directories
  un_comment_jmake
  iad
  build_aur_packages
  build_local_packages
  copy_aur_deps
  copy_build_pkg
  categorize_packages "$OUTPUT_DIR"
}

main
