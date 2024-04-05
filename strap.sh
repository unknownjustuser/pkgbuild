#!/bin/bash

pacman -Syy
pacman-key --init
pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 3056513887B78AEB
pacman-key --lsign-key 3056513887B78AEB
pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst'
echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf
echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf
echo "" >>/etc/pacman.conf
pacman -Syy --noconfirm --quiet wget
bash <(wget -qO- https://blackarch.org/strap.sh)
