FROM docker.io/library/archlinux:base-devel
# LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV PATH="/src/bin:/src/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
ENV TERM=dumb
ENV PAGER=cat

RUN sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen && \
  locale-gen && \
  echo "LANG=en_US.UTF-8" > /etc/locale.conf && \
  echo "KEYMAP=us" > /etc/vconsole.conf

# Configure environment
RUN pacman-key --init && \
  pacman -Syy && \
  pacman-key --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 3056513887B78AEB && \
  pacman-key --lsign-key 3056513887B78AEB && \
  pacman --noconfirm -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-'{keyring,mirrorlist}'.pkg.tar.zst' && \
  echo "[multilib]" >>/etc/pacman.conf && echo "Include = /etc/pacman.d/mirrorlist" >>/etc/pacman.conf && \
  echo -e "\\n[chaotic-aur]\\nInclude = /etc/pacman.d/chaotic-mirrorlist" >>/etc/pacman.conf && \
  echo "" >>/etc/pacman.conf
RUN pacman -Syy --noconfirm --needed --noprogressbar wget bash && \
  bash <(wget -qO- https://blackarch.org/strap.sh) && \
  sed -i 's/^#Server = https/Server = https/' /etc/pacman.d/blackarch-mirrorlist && \
  echo "$GPG_PRIV" >/priv.asc && \
  echo "$GPG_PUB" >/pub.asc && \
  gpg --import /*.asc && \
  sudo pacman-key --add /*.asc && \
  sudo pacman-key --lsign-key 5357F2D3B5E38D00 && \
  rm -rf /*.asc && \
  pacman -Syyu --noconfirm --needed --noprogressbar

RUN pacman -Sy --noprogressbar --noconfirm alsa-utils archiso audit aurutils autoconf b43-fwcutter base base-devel bcachefs-tools btrfs-progs ca-certificates cloud-init cmake cronie curl darkhttpd devtools diffutils docker docker-buildx docker-compose dosfstools fakeroot file git git-lfs glibc-locales gnu-netcat gnupg grep gzip jq less lib32-readline lib32-zlib libinput linux linux-atm linux-firmware linux-firmware-marvell lsb-release lsof make man man-db man-pages mariadb mariadb-clients mkinitcpio mkinitcpio-firmware mkinitcpio-nfs-utils mtools namcap nano net-tools openssh openssl parallel paru pkgconf postgresql-libs python python-apprise python-pip reflector retry rsync shellcheck sof-firmware sqlite squashfs-tools sudo syslinux systemd-resolvconf tar tzdata unzip vim wget wireless_tools wireless-regdb yay yq zip zsync

RUN useradd -m -d /src -G wheel -g users builder -s /bin/bash
RUN sed -i "s/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL$/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN chown -R builder:builder /src
# RUN chmod g+ws /src
# RUN setfacl -m u::rwx,g::rwx /src
# RUN setfacl -d --set u::rwx,g::rwx,o::- /src

# RUN sudo -u builder touch /src/.gitconfig

RUN pacman -Scc --noconfirm
RUN pacman -Syy

USER builder
WORKDIR /src

RUN whoami
# opt-out of the new security feature, not needed in a CI environment
RUN git config --global --add safe.directory '*'

COPY --chown=builder:users . .

ENTRYPOINT [ "main.sh" ]
# CMD [ "-s", "-f", "--noconfirm", "--needed", "--noprogressbar" ]
