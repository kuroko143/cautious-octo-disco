#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

mkdir -p /usr/lib/bootc/kargs.d
printf 'kargs = ["amdgpu.ppfeaturemask=0xffffffff"]\n' > /usr/lib/bootc/kargs.d/10-amdgpu.toml
dnf5 -y copr enable ilyaz/LACT
dnf5 -y install lact
dnf5 -y copr disable ilyaz/LACT
systemctl enable lactd

dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/docker-ce.repo
dnf -y install --enablerepo=docker-ce-stable \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    docker-model-plugin

systemctl enable docker.service docker.socket
systemctl enable podman.socket

tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/vscode.repo
dnf -y install --enablerepo=code code

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
dnf5 -y install busybox nix nix-daemon
systemctl enable nix.mount
systemctl enable nix-daemon

dnf5 -y install samba wsdd
systemctl enable smb.service
systemctl enable nmb.service
systemctl enable wsdd.service
firewall-offline-cmd --add-service=samba
firewall-offline-cmd --add-service=wsdd

dnf5 -y remove \
    lutris \
    waydroid

dnf5 -y install \
    alsa-plugins-a52.x86_64 \
    fastfetch \
    fuse-sshfs \
    i2c-tools \
    kitty \
    liquidctl \
    lm_sensors \
    openrgb-udev-rules \
    p7zip \
    p7zip-plugins \
    stow \
    unzip \
    usbutils \
    zip

dnf5 -y copr enable avengemedia/danklinux
dnf5 -y copr enable ulysg/xwayland-satellite
dnf5 -y install \
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
    swaylock \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    xwayland-satellite
dnf5 -y copr disable avengemedia/danklinux
dnf5 -y copr disable ulysg/xwayland-satellite

dnf5 -y install \
    ark \
    dolphin \
    kde-partitionmanager \
    kio-extras \
    mpv \
    qimgv

systemctl disable gdm.service
systemctl mask gdm.service
systemctl enable greetd.service
