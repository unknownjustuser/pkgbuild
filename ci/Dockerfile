# Do not edit individual Dockerfiles manually. Instead, please make changes to the Dockerfile.template, which will be used by the build script to generate Dockerfiles.

FROM archlinux:latest

LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

ENV PATH="/home/cirrusci/bin:/home/cirrusci/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
  locale-gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=us" > /etc/vconsole.conf

# Configure environment
RUN pacman-key --init && \
  pacman-key --keyserver keyserver.ubuntu.com --recv-key 3056513887B78AEB && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf

RUN pacman-key --init && \
  pacman-key --keyserver keyserver.ubuntu.com --recv-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3 && \
  pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3 && \
  pacman --noconfirm -U "https://www.blackarch.org/keyring/blackarch-keyring.pkg.tar'{.xz,sig}'" && \
  curl -O https://blackarch.org/blackarch-mirrorlist /etc/pacman.d/blackarch-mirrorlist && \
  chmod 644 /etc/pacman.d/blackarch-mirrorlist && \
  sudo sed -i 's/^#Server = https/Server = https/g' /etc/pacman.d/blackarch-mirrorlist && \
  echo -e "\\n[blackarch]\\nInclude = /etc/pacman.d/blackarch-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf && \
  sudo pacman -Syy

RUN pacman -Syyu --noprogressbar --noconfirm --quiet yay alsa-utils archiso audit aurutils autoconf b43-fwcutter base base-devel bcachefs-tools btrfs-progs ca-certificates cloud-init cmake curl darkhttpd devtools diffutils docker docker-buildx docker-compose dosfstools fakeroot file git git-lfs glibc-locales gnu-netcat gnupg grep gzip jq less lib32-readline lib32-zlib linux linux-atm linux-firmware linux-firmware-marvell lsb-release lsof make man man-db man-pages mariadb mariadb-clients mkinitcpio mkinitcpio-archiso mkinitcpio-firmware mkinitcpio-nfs-utils mtools namcap nano net-tools openssh openssl parallel pkgconf postgresql-libs python python-apprise reflector retry rsync shellcheck sof-firmware sqlite squashfs-tools sudo syslinux systemd-resolvconf tar tzdata unzip vim wget wireless_tools wireless-regdb yq zip zsync openmp upx optipng svgo polly paru reflector rsync curl wget git-lfs openssh devtools git lib32-readline lib32-zlib namcap fakeroot audit grep diffutils parallel

RUN sed -i 's|^NoProgressBar|#NoProgressBar|g' /etc/pacman.conf
RUN groupadd --gid=1002 cirrusci
RUN	useradd --uid=1001 --gid=cirrusci --create-home cirrusci
RUN	echo "cirrusci ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/50-cirrusci
RUN	sudo -u cirrusci mkdir /home/cirrusci/bin
RUN	sudo -u cirrusci mkdir -p /home/cirrusci/.local/bin
RUN	sudo -u cirrusci touch /home/cirrusci/.gitconfig
RUN pacman -Scc --noconfirm
RUN pacman -Syy

USER cirrusci

# Match the default cirrusci working directory
WORKDIR /home/cirrusci
