#!/bin/bash
# shellcheck disable=SC2035

repo_dir="/home/cirrusci/repo"
# x86_64_dir="$repo_dir/x86_64"

install_deps() {
  # Update the system and install essential x86_64
  sudo pacman -Syy --noconfirm --quiet --needed --noprogressbar archlinux-keyring
}

setup_archfiery_gpg() {
  gpg --recv-keys 5357F2D3B5E38D00
  echo "$GPG_PRIV" >~/priv.asc
  sudo chown -R cirrusci:cirrusci *
  gpg --import ~/priv.asc
  sudo pacman-key --import ~/priv.asc
  rm -rf ~/priv.asc
  sudo pacman-key --recv-key 5357F2D3B5E38D00 --keyserver keyserver.ubuntu.com
  sudo pacman-key --finger 5357F2D3B5E38D00
  sudo pacman-key --lsign-key 5357F2D3B5E38D00
  sudo pacman -Syy
}

setup_makepkg() {
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

  for pattern in *.{db,db.sig,db.tar.gz,db.tar.gz.sig,files,files.sig,files.tar.gz,files.tar.gz.sig,old}; do
    rm -f "$pattern"
  done

  remove_if_exists() {
    file_pattern="$1"
    if [[ -f "$file_pattern" ]]; then
      rm "$file_pattern"
    fi
  }

  remove_if_exists "$repo_dir/x86_64/*.pkg.tar.zst"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.zst

  remove_if_exists "$repo_dir/x86_64/*.pkg.tar.gz"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.gz

  remove_if_exists "$repo_dir/x86_64/*.pkg.tar.xz"
  repo-add --verify --sign archfiery_repo.db.tar.gz *.pkg.tar.xz

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
