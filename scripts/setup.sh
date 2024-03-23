#!/bin/bash
# shellcheck disable=SC2035

repo_dir="/home/cirrusci/repo"

install_deps() {
  sudo pacman -Syyu --noconfirm --needed archlinux-keyring
}

setup_archfiery_gpg() {
  gpg --recv-keys 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  echo "$GPG_PRIV" >priv.asc
  sudo chown cirrusci:cirrusci priv.asc
  gpg --import priv.asc
  sudo pacman-key --import priv.asc
  rm priv.asc
  sudo pacman-key --keyserver keyserver.ubuntu.com --recv-key 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  sudo pacman-key --lsign-key 38B3A1DCEE2408A5BFA63E105357F2D3B5E38D00
  curl -O https://blackarch.org/strap.sh
  sha1sum --check <(echo "26849980b35a42e6e192c6d9ed8c46f0d6d06047 strap.sh")
  chmod +x strap.sh
  sudo ./strap.sh
  rm strap.sh
  sudo sed -i 's/^#Server = https/Server = https/g' /etc/pacman.d/blackarch-mirrorlist
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
[options]
PgpFetch
Devel
Provides
DevelSuffixes = -git -cvs -svn -bzr -darcs -always -hg -fossil
SudoLoop
KeepRepoCache
SkipReview
Sign
EOF
}

setup_repo() {
  cd "$repo_dir/x86_64" || exit

  for pattern in *.{db,db.sig,db.tar.gz,db.tar.gz.sig,files,files.sig,files.tar.gz,files.tar.gz.sig,old}; do
    rm -f "$pattern"
  done

  pkg_files=()
  if [[ -n $(
    shopt -s nullglob
    echo *.pkg.tar.zst
  ) ]]; then
    pkg_files+=('*.pkg.tar.zst')
  fi
  if [[ -n $(
    shopt -s nullglob
    echo *.pkg.tar.gz
  ) ]]; then
    pkg_files+=('*.pkg.tar.gz')
  fi
  if [[ -n $(
    shopt -s nullglob
    echo *.pkg.tar.xz
  ) ]]; then
    pkg_files+=('*.pkg.tar.xz')
  fi

  if [[ ${#pkg_files[@]} -gt 0 ]]; then
    repo-add --verify --sign archfiery_repo.db.tar.gz "${pkg_files[@]}"
  else
    echo "No package files found to add to the repository."
  fi

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
  setup_paru_conf
  setup_repo
  setup_git
}

main "$@"
