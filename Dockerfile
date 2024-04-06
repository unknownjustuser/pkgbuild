FROM docker.io/library/archlinux:base-devel
LABEL maintainer="unknownjustuser <unknown.just.user@proton.me>"

SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV PATH="/home/builder/bin:/home/builder/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/core_perl:$PATH"
ENV TERM=dumb
ENV PAGER=cat

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
RUN pacman -Syy --noconfirm --needed --noprogressbar wget bash && \
  bash <(wget -qO- https://blackarch.org/strap.sh) && \
  pacman -Syyu --noconfirm --needed --noprogressbar

RUN pacman -Sy --noprogressbar --noconfirm alsa-utils archiso audit aurutils autoconf b43-fwcutter base base-devel bcachefs-tools btrfs-progs ca-certificates cloud-init cmake cronie curl darkhttpd devtools diffutils docker docker-buildx docker-compose dosfstools fakeroot file git git-lfs glibc-locales gnu-netcat gnupg grep gzip jq less lib32-readline lib32-zlib libinput linux linux-atm linux-firmware linux-firmware-marvell lsb-release lsof make man man-db man-pages mariadb mariadb-clients mkinitcpio mkinitcpio-firmware mkinitcpio-nfs-utils mtools namcap nano net-tools openssh openssl parallel paru pkgconf postgresql-libs python python-apprise python-pip reflector retry rsync shellcheck sof-firmware sqlite squashfs-tools sudo syslinux systemd-resolvconf tar tzdata unzip vim wget wireless_tools wireless-regdb yay yq zip zsync

RUN useradd -m -G wheel -s /bin/bash builder
RUN sed -i "s/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL$/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/" /etc/sudoers
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers
RUN echo "root ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

RUN chown -R builder:builder /home/builder/
RUN chmod g+ws /home/builder
RUN setfacl -m u::rwx,g::rwx /home/builder
RUN setfacl -d --set u::rwx,g::rwx,o::- /home/builder

RUN sudo -u builder mkdir /home/builder/bin
RUN sudo -u builder mkdir -p /home/builder/.local/bin
RUN sudo -u builder touch /home/builder/.gitconfig
RUN	sudo -u builder git config --global --add safe.directory '*'
RUN sudo -u buidler sudo chown -R builder:builder .*
RUN sudo -u buidler sudo chown -R builder:builder *
RUN sudo -u builder eval $(ssh-agent -s)
RUN sudo -u builder echo "$SSH_PRIV_KEY" | tr -d '\r' | ssh-add -
RUN sudo -u builder mkdir -p /home/builder/.ssh
RUN sudo -u builder touch /home/builder/.ssh/config
RUN sudo -u builder touch /home/builder/.ssh/known_hosts
RUN sudo -u builder ssh-keyscan github.com >/home/builder/.ssh/known_hosts

RUN sudo -u builder sudo usermod -a -G docker builder
RUN sudo -u builder sudo systemctl enable docker

RUN sudo -u buidler sudo chown -R builder:builder .*
RUN sudo -u buidler sudo chown -R builder:builder *
RUN sudo -u buidler git clone git@github.com:unknownjustuser/repo.git /home/builder/repo
RUN sudo -u buidler sudo chown -R builder:builder .*
RUN sudo -u buidler sudo chown -R builder:builder *

RUN pacman -Scc --noconfirm
RUN pacman -Syy

USER builder
RUN whoami && \
	# opt-out of the new security feature, not needed in a CI environment
	git config --global --add safe.directory '*'
WORKDIR /home/builder

ENTRYPOINT [ "main.sh" ]
