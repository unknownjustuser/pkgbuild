#!/bin/bash
# shellcheck disable=SC2035

# Script name: build.sh
# Description: Automate push script to push changes to github "cirrus CI".
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

# Lowercase variable names
pkg_dir="/home/builder/repo"
pkgbuild_repo="/home/builder/packages"
parucache="/home/builder/.cache/paru/clone"
current_date=$(date +"%d-%m-%Y")

copy_pkg() {
  for dir in "$pkgbuild_repo"/*/ "$parucache"/*/; do
    if [[ -n $(find "$dir" -maxdepth 1 -type f -name '*.pkg.tar.*') ]]; then
      cp -r "$dir"/*.pkg.tar.* "$pkg_dir/x86_64"
    fi
  done
}

update-db() {
  cd "$pkg_dir/x86_64" || exit
  chmod +x update-db.sh
  ./update-db.sh
  cd - || exit
}

push_repo_dir() {
  cd "$pkg_dir" || exit
  git add .
  git add *
  git commit -m "Packages builded on $current_date"
  git push origin main
  cd - || exit
}

main() {
  copy_pkg
  update-db
  push_repo_dir
}

main
