#!/bin/bash
# shellcheck disable=SC2035

repo_dir="/home/cirrusci/repo"
pkg_dir="/var/cache/pacman/archfiery"
# x86_64_dir="$repo_dir/x86_64"

install_deps() {
  # Update the system and install essential x86_64
  sudo pacman -Syy --noconfirm --quiet --needed --noprogressbar archlinux-keyring
}

setup_archfiery_gpg() {
  echo $GPG_PRIV >~/priv.asc
  echo $GPG_PUB >~/pub.asc
  sudo chown -R cirrusci:cirrusci *
  gpg --import ~/*.asc
  sudo pacman-key --add ~/*.asc
  sudo pacman-key --lsign-key 5357F2D3B5E38D00
  rm -rf ~/*.asc
  sudo pacman -Syy
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
# $PARU_CONF
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
SudoLoop
CleanAfter

LocalRepo
#Chroot
Sign
#SignDb
KeepRepoCache
SkipReview

EOF
}

setup_repo() {
  sudo chmod 777 *
  cp -r "$repo_dir/x86_64/*" "$pkg_dir"

  cd "$pkg_dir" || exit

  for pattern in *.{db,db.sig,db.tar.gz,db.tar.gz.sig,files,files.sig,files.tar.gz,files.tar.gz.sig,old}; do
    rm -f "$pattern"
  done

  remove_if_exists() {
    file_pattern="$1"
    if [[ -f "$file_pattern" ]]; then
      rm "$file_pattern"
    fi
  }

  remove_if_exists "$pkg_dir/*.pkg.tar.zst"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.zst

  remove_if_exists "$pkg_dir/*.pkg.tar.gz"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.gz

  remove_if_exists "$pkg_dir/*.pkg.tar.xz"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.xz

  sudo chmod 777 *
  cd - || exit

  sudo tee -a /etc/pacman.conf <<EOF

[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /var/cache/pacman/archfiery
CleanMethod = KeepCurrent

[archfiery_repo]
SigLevel = Required DatabaseOptional
Server = file:///var/cache/pacman/archfiery

EOF

  ls -al "$repo_dir/x86_64"

  sudo pacman -Syy
}

setup_git() {
  cat >>/home/cirrusci/.gitconfig <<EOF
[user]
	email = unknown.just.user@proton.me
	name = unknownjustuser
[init]
	defaultBranch = main
[core]
	autocrlf = false
[merge]
	tool = meld
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
EOF
}

main() {
  install_deps
  setup_archfiery_gpg
  setup_makepkg
  setup_paru_conf
  setup_repo
  setup_git
}

main "$@"
