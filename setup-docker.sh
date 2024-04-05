#!/bin/bash

pacman -Scc --noconfirm
pacman -Syy

pacman -Syy --noconfirm --quiet --needed archlinux-keyring blackarch-keyring yay archiso audit aurutils cmake curl devtools libinput docker docker-buildx docker-compose glibc-locales gnupg grep gzip jq less make man namcap openssh openssl parallel pkgconf python python-apprise python-pip rsync squashfs-tools tar unzip vim wget yq zip paru reflector git-lfs openssh git namcap audit grep diffutils parallel cronie btrfs-progs sudo

useradd -m -d /home/builder -s /bin/bash -G wheel builder
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
usermod -a -G docker builder
usermod -a -G libinput builder
chown -R builder:builder /home/builder/

PATH="$HOME/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
