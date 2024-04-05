#!/bin/bash

pacman -Scc --noconfirm
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

if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo 'KEYMAP=us' > /etc/vconsole.conf

pacman -Syy --noconfirm --quiet --needed archlinux-keyring blackarch-keyring yay archiso audit aurutils cmake curl devtools libinput docker docker-buildx docker-compose glibc-locales gnupg grep gzip jq less make man namcap openssh openssl parallel pkgconf python python-apprise python-pip rsync squashfs-tools tar unzip vim wget yq zip paru reflector git-lfs openssh git namcap audit grep diffutils parallel cronie

useradd -m -d /home/builder -s /bin/bash -G wheel builder
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/g' /etc/sudoers
echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
usermod -a -G docker builder
usermod -a -G libinput builder
chown -R builder:builder /home/builder/

PATH="$HOME/bin:$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
