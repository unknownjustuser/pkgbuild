#!/bin/sh

GPG_CONF='/etc/pacman.d/gnupg/gpg.conf'

# Simple error message wrapper
err() {
  echo >&2 "$(
    tput bold
    tput setaf 1
  )[-] ERROR: ${*}$(tput sgr0)"
  exit 1
}

# Simple warning message wrapper
warn() {
  echo >&2 "$(
    tput bold
    tput setaf 1
  )[!] WARNING: ${*}$(tput sgr0)"
}

# Simple echo wrapper
msg() {
  echo "$(
    tput bold
    tput setaf 2
  )[+] ${*}$(tput sgr0)"
}

# Check for root privilege
check_priv() {
  if [ "$(id -u)" -ne 0 ]; then
    err "You must be root"
  fi
}

# Make a temporary directory and cd into it
make_tmp_dir() {
  tmp="$(mktemp -d /tmp/strap.XXXXXXXX)"
  trap 'rm -rf $tmp' EXIT
  cd "$tmp" || err "Could not enter directory $tmp"
}

set_umask() {
  OLD_UMASK=$(umask)
  umask 0022
  trap 'reset_umask' TERM
}

reset_umask() {
  umask "$OLD_UMASK"
}

# Add necessary GPG options
add_gpg_opts() {
  # Temporary fix for SHA-1 + >= gpg-2.4 versions
  if ! grep -q 'allow-weak-key-signatures' "$GPG_CONF"; then
    echo 'allow-weak-key-signatures' >>"$GPG_CONF"
  fi
}

fetch_keyrings() {
  curl -s -O \
    "https://www.blackarch.org/keyring/blackarch-keyring.pkg.tar.{xz,xz.sig}"

  curl -s -O \
    "https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.{zst,zst.sig}"
}

# Verify the keyring signatures
verify_keyrings() {
  # BlackArch
  if ! gpg --keyserver keyserver.ubuntu.com \
    --recv-keys 4345771566D76038C7FEB43863EC0ADBEA87E4E3 >/dev/null 2>&1; then
    if ! gpg --keyserver hkps://keyserver.ubuntu.com:443 \
      --recv-keys 4345771566D76038C7FEB43863EC0ADBEA87E4E3 >/dev/null 2>&1; then
      if ! gpg --keyserver hkp://pgp.mit.edu:80 \
        --recv-keys 4345771566D76038C7FEB43863EC0ADBEA87E4E3 >/dev/null 2>&1; then
        err "Could not verify the key. Please check: https://blackarch.org/faq.html"
      fi
    fi
  fi

  # ChaoticAur
  if ! gpg --keyserver keyserver.ubuntu.com \
    --recv-keys 3056513887B78AEB >/dev/null 2>&1; then
    if ! gpg --keyserver hkps://keyserver.ubuntu.com:443 \
      --recv-keys 3056513887B78AEB >/dev/null 2>&1; then
      err "Could not verify the ChaoticAur key."
    fi
  fi

  # Check
  if ! gpg --keyserver-options no-auto-key-retrieve \
    --with-fingerprint blackarch-keyring.pkg.tar.xz.sig >/dev/null 2>&1; then
    err "Invalid keyring signature 'blackarch-keyring'. Please stop by https://matrix.to/#/#/BlackaArch:matrix.org"
  fi

  if ! gpg --keyserver-options no-auto-key-retrieve \
    --with-fingerprint chaotic-keyring.pkg.tar.zst.sig >/dev/null 2>&1; then
    err "Invalid keyring signature 'chaotic-keyring'."
  fi
}

# Delete the signature files
delete_signatures() {
  if [ -f "blackarch-keyring.pkg.tar.xz.sig" ] ||
    [ -f "chaotic-keyring.pkg.tar.zst.sig" ]; then
    rm blackarch-keyring.pkg.tar.xz.sig \
      chaotic-keyring.pkg.tar.zst.sig
  fi
}

# Make sure /etc/pacman.d/gnupg is usable
check_pacman_gnupg() {
  pacman-key --init
}

# Install the keyrings
install_keyrings() {
  if ! pacman --config /dev/null --noconfirm \
    -U blackarch-keyring.pkg.tar.xz \
    chaotic-keyring.pkg.tar.zst; then
    err 'Keyring installation failed'
  fi

  # Just in case
  pacman-key --populate
}

# Ask user for mirror
get_mirrors() {
  mirror_path="/etc/pacman.d" # Mirror file to fetch and write
  MIRROR_B='blackarch-mirrorlist'
  MIRROR_C='chaotic-mirrorlist'
  blackarch_url="https://blackarch.org"
  chaotic_url="https://raw.githubusercontent.com/chaotic-aur/pkgbuild-chaotic-mirrorlist/main/mirrorlist"

  if ! curl -s "$blackarch_url/$MIRROR_B" -o "$mirror_path/$MIRROR_B"; then
    err "We couldn't fetch the BlackArch mirror list"
  fi

  if ! curl -s "$chaotic_url/$MIRROR_C" -o "$mirror_path/$MIRROR_C"; then
    err "We couldn't fetch the ChaoticAur mirror list"
  fi
}

# Update pacman.conf
update_pacman_conf() {
  # Enable multilib
  {
    echo "[multilib]"
    echo "Include = /etc/pacman.d/mirrorlist"
    echo ""
  } >>/etc/pacman.conf

  # Add repositories
  sed -i '/blackarch/{N;d}' /etc/pacman.conf
  sed -i '/chaotic-aur/{N;d}' /etc/pacman.conf

  cat >>"/etc/pacman.conf" <<EOF

[blackarch]
Include = /etc/pacman.d/$MIRROR_B

[chaotic-aur]
Include = /etc/pacman.d/$MIRROR_C
EOF
}

# Synchronize and update
pacman_update() {
  if pacman -Syy; then
    return 0
  fi

  warn "Synchronizing pacman has failed. Please try manually: pacman -Syy"
  return 1
}

pacman_upgrade() {
  if pacman -Su; then
    return 0
  fi
}

# Setup Archfiery, BlackArch, and ChaoticAur Linux keyrings
setup_keyrings() {
  msg 'Installing Archfiery, BlackArch, and ChaoticAur keyrings...'
  check_priv
  set_umask
  make_tmp_dir
  add_gpg_opts
  fetch_keyrings
  verify_keyrings
  delete_signatures
  check_pacman_gnupg
  install_keyrings

  echo
  msg 'Keyrings installed successfully'
  if ! grep -q "\[blackarch\]" "\[chaotic-aur\]" /etc/pacman.conf; then
    msg 'Configuring pacman'
    get_mirrors
    msg 'Updating pacman.conf'
    update_pacman_conf
  fi
  msg 'Updating package databases'
  pacman_update
  pacman_upgrade
  reset_umask
  msg 'Done!'
}

setup_keyrings
