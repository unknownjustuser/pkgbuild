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

curl -s https://blackarch.org/blackarch-mirrorlist -o /etc/pacman.d/blackarch-mirrorlist

{
  echo ""
  echo "[multilib]"
  echo "Include = /etc/pacman.d/mirrorlist"
  echo ""
  echo "[blackarch]"
  echo "Include = /etc/pacman.d/blackarch-mirrorlist"
  echo ""
  echo "[chaotic-aur]"
  echo "Include = /etc/pacman.d/chaotic-mirrorlist"
} >>/etc/pacman.conf
