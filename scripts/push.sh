#!/bin/bash

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

# add_repo_lfs() {
#   cd "$repo_dir"
#   # Install Git LFS
#   git lfs install
#   # Configure Git attributes
#   cat >>.gitattributes <<EOF
# *.zst filter=lfs diff=lfs merge=lfs -text
# *.zst !text !filter !merge !diff
# EOF
#   # Track large packages with Git LFS
#   for package in "$repo_dir/x86_64"/*.pkg.tar.*; do
#     if [[ $(stat -c %s "$package") -gt 100000000 ]]; then
#       name=$(basename "$package")
#       echo "Tracking $name with Git LFS"
#       git lfs track "$name"

#       # Add the package and commit it
#       git add "$name"
#       git commit -m "Add $name built on $current_date"
#     fi
#   done
# }

push_repo_dir() {
  cd "$repo_dir" || exit
  git add .
  git add ./*
  git commit -m "Add built packages on $current_date"
  git remote set-url origin https://"$GITHUB_TOKEN"@github.com/unknownjustuser/repo.git
  git push origin main
}

# push_pkgbuild_repo() {
#   cd "$pkgbuild_repo" || exit
#   git add .
#   git commit -m "Updated on $current_date"
#   git remote set-url origin https://"$GITLAB_TOKEN"@gitlab.com/arch-linuxf/pkgbuild.git
#   git push -u origin main
# }

main() {
  copy_pkg
  update-db
  # add_repo_lfs
  push_repo_dir
  # push_pkgbuild_repo
}

main "$@"
