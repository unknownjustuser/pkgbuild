#!/bin/bash

# Update package repositories
pacman -Syy --noconfirm

# Initialize and import GPG keys
pacman-key --init
pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 3056513887B78AEB
pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3
pacman-key --lsign-key 3056513887B78AEB 4345771566D76038C7FEB43863EC0ADBEA87E4E3

# Install Chaotic AUR and BlackArch keyring and mirror list
pacman --noconfirm -U "https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-"{keyring,mirrorlist}".pkg.tar.zst" "https://www.blackarch.org/keyring/blackarch-keyring.pkg.tar.{xz,xz.sig}"

# Fetch BlackArch and Chaotic AUR mirror lists
mirror_path="/etc/pacman.d"
MIRROR_B="blackarch-mirrorlist"
blackarch_url="https://blackarch.org"

curl -s "$blackarch_url/$MIRROR_B" -o "$mirror_path/$MIRROR_B"

cat >>"/etc/pacman.conf" <<EOF

[multilib]
Include = /etc/pacman.d/mirrorlist

[blackarch]
Include = /etc/pacman.d/blackarch-mirrorlist

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
