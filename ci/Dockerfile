# Do not edit individual Dockerfiles manually. Instead, please make changes to the Dockerfile.template, which will be used by the build script to generate Dockerfiles.

FROM archlinux:base-devel

LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

ENV PATH="/home/cirrusci/bin:/home/cirrusci/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
  locale-gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=us" > /etc/vconsole.conf

# Configure environment
RUN pacman -Syy && \
  pacman-key --init && \
  pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 3056513887B78AEB && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf

RUN pacman -Syy --noconfirm --needed --noprogressbar wget
  bash <(wget -qO- https://blackarch.org/strap.sh) && \
  pacman -Syyu --noconfirm --needed --noprogressbar

RUN pacman -Syyu --noprogressbar --noconfirm yay archiso audit aurutils autoconf base base-devel cmake curl devtools docker docker-buildx docker-compose fakeroot glibc-locales gnu-netcat gnupg grep gzip jq less lib32-readline lib32-zlib linux linux-atm linux-firmware linux-firmware-marvell lsof make man man-db man-pages mkinitcpio mkinitcpio-archiso mkinitcpio-firmware mkinitcpio-nfs-utils mtools namcap nano net-tools openssh openssl parallel pkgconf python python-apprise python-pip reflector retry rsync shellcheck sof-firmware squashfs-tools tar unzip vim wget yq zip paru reflector git-lfs openssh git namcap fakeroot audit grep diffutils parallel lsb-release cronie

RUN sed -i 's|^NoProgressBar|#NoProgressBar|g' /etc/pacman.conf
RUN groupadd --gid=1002 cirrusci
RUN	useradd --uid=1001 --gid=cirrusci --create-home cirrusci
RUN	echo "cirrusci ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/50-cirrusci
RUN	sudo -u cirrusci mkdir /home/cirrusci/bin
RUN	sudo -u cirrusci mkdir -p /home/cirrusci/.local/bin
RUN	sudo -u cirrusci touch /home/cirrusci/.gitconfig
RUN pacman -Scc --noconfirm
RUN pacman -Syy

USER cirrusci

# Match the default cirrusci working directory
WORKDIR /home/cirrusci
