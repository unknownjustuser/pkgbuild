#!/bin/bash
# shellcheck disable=SC2035

repo_dir="/home/cirrusci/repo"
# x86_64_dir="$repo_dir/x86_64"

install_deps() {
  # Update the system and install essential x86_64
  sudo pacman -Syy --noconfirm --quiet --needed --noprogressbar archlinux-keyring
}

setup_archfiery_gpg() {
  gpg --recv-keys 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  echo "$GPG_PRIV" >~/priv.asc
  sudo chown -R cirrusci:cirrusci *
  gpg --import ~/priv.asc
  sudo pacman-key --import ~/priv.asc
  rm -rf ~/priv.asc
  sudo pacman-key --keyserver keyserver.ubuntu.com --recv-key 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  sudo pacman-key --finger 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  sudo pacman-key --lsign-key 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  curl -O https://blackarch.org/strap.sh
  echo 26849980b35a42e6e192c6d9ed8c46f0d6d06047 strap.sh | sha1sum -c
  chmod +x strap.sh
  sudo ./strap.sh
  rm -rf strap.sh
  sudo pacman -Syyu
  sudo sed -i 's/^#Server = https/Server = https/g' /etc/pacman.d/blackarch-mirrorlist
  sudo pacman -Syy
}

setup_makepkg() {
  # sudo mv /etc/makepkg.conf /etc/makepkg.conf.old
  # sudo mv /etc/makepkg-optimize.conf /etc/makepkg.conf
  sudo sed -i 's|^#\(BUILDDIR=\).*|\1/tmp/makepkg|' /etc/makepkg.conf
  sudo sed -i 's|BUILDENV=.*|BUILDENV=(!distcc color !ccache check sign)|' /etc/makepkg.conf
  sudo sed -i 's|^#PACKAGER=.*|PACKAGER="unknownjustuser (archfiery) <unknown.just.user@proton.me>"|' /etc/makepkg.conf
  sudo sed -i 's|^#GPGKEY=.*|GPGKEY="5357F2D3B5E38D00"|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSGZ=\).*|\1\(gzip -c -f -n --best\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSBZ2=\).*|\1\(bzip2 -c -f --best\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSXZ=\).*|\1\(xz -T0 -c -z --best -\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSZST=\).*|\1\(zstdmt -c -z -q --ultra -22 -\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSLRZ=\).*|\1\(lrzip -9 -q\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSLZO=\).*|\1\(lzop -q --best\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSZ=\).*|\1\(compress -c -f\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSLZ4=\).*|\1\(lz4 -q --best\)|' /etc/makepkg.conf
  # sudo sed -i 's|^#\(COMPRESSLZ=\).*|\1\(lzip -c -f\)|' /etc/makepkg.conf
}

# setup_pacman_conf() {
#   sudo sed -i 's|^NoProgressBar|#NoProgressBar|g' /etc/pacman.conf
#   sudo sed -i 's|^#Color|Color|g' /etc/pacman.conf
# }

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
#AurOnly
#BottomUp
#RemoveMake
SudoLoop
#UseAsk
#SaveChanges
#CombinedUpgrade
#CleanAfter
#UpgradeMenu
#NewsOnUpgrade

#LocalRepo
#Chroot
Sign
#SignDb
KeepRepoCache
SkipReview

#
# Binary OPTIONS
#
#[bin]
#FileManager = vifm
#MFlags = --skippgpcheck
#Sudo = doas

EOF
}

setup_repo() {
  # sudo mkdir -p "$repo_dir/x86_64"
  # sudo install -d "$repo_dir/x86_64" -o "$USER"

  # if [[ ! -f "$x86_64_dir/archfiery_repo.*" ]]; then
  #   sudo -u cirrusci repo-add /var/cache/pacman/archfiery_repo/archfiery_repo.db.tar.gz
  # fi

  sudo chmod 777 *
  cd "$repo_dir/x86_64" || exit

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.db" ]]; then
    rm -f *.db
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.db.sig" ]]; then
    rm -f *.db.sig
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.db.tar.gz" ]]; then
    rm -f *.db.tar.gz
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.db.tar.gz.sig" ]]; then
    rm -f *.db.tar.gz.sig
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.files" ]]; then
    rm -f *.files
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.files.sig" ]]; then
    rm -f *.files.sig
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.files.tar.gz" ]]; then
    rm -f *.files.tar.gz
  fi

  if [[ ! -f "$repo_dir/x86_64/archfiery_repo.files.tar.gz.sig" ]]; then
    rm -f *.files.tar.gz.sig
  fi

  if [[ ! -f "$repo_dir/x86_64/*.old" ]]; then
    rm -f *.old
  fi

  if [[ ! -f "$repo_dir/x86_64/*.pkg.tar.zst" ]]; then
    repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.zst
  fi

  sudo chmod 777 *
  cd - || exit

  sudo tee -a /etc/pacman.conf <<EOF

[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /home/cirrusci/repo/x86_64
CleanMethod = KeepCurrent

[archfiery_repo]
SigLevel = Required DatabaseOptional
Server = file:///home/cirrusci/repo/x86_64

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
  # setup_pacman_conf
  setup_paru_conf
  setup_repo
  setup_git
}

main "$@"
