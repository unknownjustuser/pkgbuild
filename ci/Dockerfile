# Do not edit individual Dockerfiles manually. Instead, please make changes to the Dockerfile.template, which will be used by the build script to generate Dockerfiles.

FROM archlinux:base-devel

LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

# Change default shell for RUN from Dash to Bash
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV TERM=dumb \
  PAGER=cat

ENV PATH="/home/cirrusci/bin:/home/cirrusci/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
  locale-gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=us" > /etc/vconsole.conf

# Configure environment
RUN pacman-key --init && \
  # pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com && \
  # pacman-key --lsign-key 3056513887B78AEB && \
  # pacman --noconfirm -U 'https://geo-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  # echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  # echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  # echo "" >>/etc/pacman.conf
  pacman-key --populate

RUN \
if grep -q "\[multilib\]" /etc/pacman.conf; then \
  sed -i '/^\[multilib\]/,/Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf; \
else \
  echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" | tee -a /etc/pacman.conf; \
fi

RUN pacman -Syyu --noprogressbar --noconfirm --quiet

RUN sed -i 's|^NoProgressBar|#NoProgressBar|g' /etc/pacman.conf
RUN groupadd --gid=1002 cirrusci
RUN	useradd --uid=1001 --gid=cirrusci --create-home cirrusci
RUN	echo "cirrusci ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/50-cirrusci
RUN	sudo -u cirrusci mkdir /home/cirrusci/bin
RUN	sudo -u cirrusci mkdir -p /home/cirrusci/.local/bin
RUN	sudo -u cirrusci touch /home/cirrusci/.gitconfig

USER cirrusci
RUN \
  cd /home/cirrusci && \
  curl -O -s https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz && \
  tar xf yay-bin.tar.gz && \
  cd yay-bin && makepkg -sci --noconfirm && cd - && \
  rm -rf yay-bin*

RUN yay -Sy --noprogressbar --noconfirm --quiet --needed alsa-utils archiso audit aurutils autoconf b43-fwcutter base base-devel bcachefs-tools btrfs-progs ca-certificates cloud-init cmake curl darkhttpd devtools diffutils docker docker-buildx docker-compose dosfstools fakeroot file git git-lfs glibc-locales gnu-netcat gnupg grep gzip jq less lib32-readline lib32-zlib linux linux-atm linux-firmware linux-firmware-marvell lsb-release lsof make man man-db man-pages mariadb mariadb-clients mkinitcpio mkinitcpio-archiso mkinitcpio-firmware mkinitcpio-nfs-utils mtools namcap nano net-tools openssh openssl parallel pkgconf postgresql-libs python python-apprise reflector retry rsync shellcheck sof-firmware sqlite squashfs-tools sudo syslinux systemd-resolvconf tar tzdata unzip vim wget wireless_tools wireless-regdb yq zip zsync openmp upx optipng svgo polly makepkg-optimize paru-bin

RUN yay -Scc --noconfirm
RUN yay -Syy

# Match the default cirrusci working directory
WORKDIR /home/cirrusci
