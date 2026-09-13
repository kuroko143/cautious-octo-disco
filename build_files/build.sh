#!/bin/bash

set -ouex pipefail

cp -avf "/ctx/system_files"/. /

mkdir -p /usr/lib/bootc/kargs.d
printf 'kargs = ["amdgpu.ppfeaturemask=0xffffffff"]\n' > /usr/lib/bootc/kargs.d/10-amdgpu.toml

dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/docker-ce.repo

tee /etc/yum.repos.d/vscode.repo <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
sed -i "s/enabled=.*/enabled=0/g" /etc/yum.repos.d/vscode.repo

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

# dnf5 -y remove lutris waydroid

dnf5 -y copr enable ilyaz/LACT
dnf5 -y copr enable atim/starship
dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable avengemedia/danklinux

dnf5 -y install --enablerepo=docker-ce-stable,code \
    containerd.io \
    docker-buildx-plugin \
    docker-ce \
    docker-ce-cli \
    docker-compose-plugin \
    docker-model-plugin \
    code \
    lact \
    busybox \
    nix \
    nix-daemon \
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
    atuin \
    eza \
    kitty \
    neovim \
    starship \
    blueman \
    dms \
    dms-greeter \
    fuzzel \
    greetd \
    greetd-selinux \
    kvantum \
    niri \
    pavucontrol \
    playerctl \
    qt6-qtmultimedia \
    qt6ct \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    https://kojipkgs.fedoraproject.org//packages/xwayland-satellite/0.8.1/1.fc44/x86_64/xwayland-satellite-0.8.1-1.fc44.x86_64.rpm \
    ark \
    dolphin \
    kde-partitionmanager \
    kio-extras \
    mpv \
    qimgv

dnf5 -y copr disable ilyaz/LACT
dnf5 -y copr disable atim/starship
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable avengemedia/danklinux

systemctl enable docker.service docker.socket podman.socket
systemctl enable lactd
systemctl enable nix.mount nix-daemon
firewall-offline-cmd --add-service=samba

systemctl disable gdm.service
systemctl mask gdm.service
systemctl enable greetd.service
