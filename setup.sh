#!/bin/bash
# shellcheck disable=SC2035

# Script name: build.sh
# Description: Automate setup script on cirrus CI.
# Contributors: unknownjustuser

# Set flags to make robust
set -euo pipefail

pkg_dir="/src/repo"

install_deps() {
  # Update the system and install essential x86_64
  sudo pacman -Syy --noconfirm --quiet --needed --noprogressbar archlinux-keyring
}

setup_makepkg() {
  sudo sed -i 's|^#\(BUILDDIR=\).*|\1/tmp/makepkg|' /etc/makepkg.conf
  sudo sed -i 's|BUILDENV=.*|BUILDENV=(!distcc color !ccache check sign)|' /etc/makepkg.conf
  sudo sed -i 's|^#PACKAGER=.*|PACKAGER="unknownjustuser (archfiery) <unknown.just.user@proton.me>"|' /etc/makepkg.conf
  sudo sed -i 's|^#GPGKEY=.*|GPGKEY="5357F2D3B5E38D00"|' /etc/makepkg.conf
}

setup_paru_conf() {
  sudo tee -a /etc/paru.conf <<EOF
#
# /etc/paru.conf
# ~/.config/paru/paru.conf
#
# See the paru.conf(5) manpage for options

#
# GENERAL OPTIONS
#
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always -hg -fossil
#SudoLoop
CleanAfter

#LocalRepo
#Chroot
Sign
#SignDb
KeepRepoCache
SkipReview

EOF
}

setup_repo() {
  sudo chmod 777 *

  cd "$pkg_dir"/x86_64 || exit
  sudo chmod 777 *

  for pattern in *.{db,db.sig,db.tar.gz,db.tar.gz.sig,files,files.sig,files.tar.gz,files.tar.gz.sig,old}; do
    rm -f "$pattern"
  done

  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.zst

  sudo chmod 777 *
  cd - || exit

  sudo tee -a /etc/pacman.conf <<EOF

[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /src/repo/x86_64
CleanMethod = KeepCurrent

[archfiery_repo]
SigLevel = Required DatabaseOptional
Server = file:///src/repo/x86_64

EOF

  ls -al "$pkg_dir"
  ls -al "$pkg_dir/x86_64"

  sudo pacman -Syy
}

setup_git() {
  cat >>/src/.gitconfig <<EOF
[user]
	email = unknown.just.user@proton.me
	name = unknownjustuser
[init]
	defaultBranch = main
[core]
	autocrlf = false
EOF
}

main() {
  install_deps
  setup_makepkg
  setup_paru_conf
  setup_repo
  setup_git
}

main
