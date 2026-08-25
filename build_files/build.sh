#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

mkdir -p /usr/lib/bootc/kargs.d
printf 'kargs = ["amdgpu.ppfeaturemask=0xffffffff"]\n' > /usr/lib/bootc/kargs.d/10-amdgpu.toml

dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/docker-ce.repo

cat <<'EOF' > /etc/systemd/system/nix.mount
[Unit]
Description=Bind mount /var/nix to /nix

[Mount]
What=/var/nix
Where=/nix
Type=none
Options=bind

[Install]
WantedBy=local-fs.target
EOF

dnf5 -y remove \
    lutris \
    waydroid

dnf5 -y copr enable ilyaz/LACT
dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable ulysg/xwayland-satellite

dnf5 -y install --enablerepo=docker-ce-stable \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    docker-model-plugin \
    lact \
    busybox \
    nix \
    nix-daemon \
    samba \
    wsdd \
    alsa-plugins-a52.x86_64 \
    fastfetch \
    fuse-sshfs \
    i2c-tools \
    liquidctl \
    lm_sensors \
    openrgb-udev-rules \
    p7zip \
    p7zip-plugins \
    stow \
    unzip \
    usbutils \
    zip \
    kitty \
    blueman \
    dms \
    dms-greeter \
    fuzzel \
    greetd \
    greetd-selinux \
    kvantum \
    niri \
    pavucontrol \
    qt6-qtmultimedia \
    qt6ct \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xwayland-satellite \
    ark \
    dolphin \
    kde-partitionmanager \
    kio-extras \
    mpv

dnf5 -y copr disable ilyaz/LACT
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable ulysg/xwayland-satellite

systemctl enable docker.service docker.socket podman.socket
systemctl enable lactd
systemctl enable nix.mount nix-daemon
systemctl enable smb.service nmb.service wsdd.service
firewall-offline-cmd --add-service=samba --add-service=wsdd

systemctl disable gdm.service
systemctl mask gdm.service
systemctl enable greetd.service
