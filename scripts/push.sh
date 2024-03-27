#!/bin/bash
# shellcheck disable=SC2035

# Script name: build-packages.sh
# Description: Script for automating push builded pkgs to repo.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

# Lowercase variable names
repo_dir="/home/cirrusci/repo"
pkgbuild_repo="/home/cirrusci/pkgbuild"
packages="$pkgbuild_repo/packages"
parucache="/home/cirrusci/.cache/paru/clone"
current_date=$(date +"%Y-%m-%d")

copy_pkg() {
  cd "$repo_dir" || exit

  for dir in "$packages"/* "$parucache"/*; do
    if [[ -n $(find "$dir" -maxdepth 1 -type f -name '*.pkg.tar.*') ]]; then
      cp -r "$dir"/*.pkg.tar.* "$repo_dir/x86_64"
    fi
  done

}

update-db() {
  cd "$repo_dir/x86_64" || exit
  chmod +x update-db.sh
  ./update-db.sh
}

push_repo_dir() {
  cd "$repo_dir" || exit
  git add .
  git add *
  git commit -m "Add built packages on $current_date"
  git remote set-url origin https://"$GITHUB_TOKEN"@github.com/unknownjustuser/repo.git
  git push origin main
}

main() {
  copy_pkg
  update-db
  push_repo_dir
}

main "$@"
