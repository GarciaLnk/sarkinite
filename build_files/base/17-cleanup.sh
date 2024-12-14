#!/usr/bin/bash

set -eoux pipefail

# Setup Systemd
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service
systemctl enable dconf-update.service
systemctl --global enable ublue-flatpak-manager.service
systemctl enable ublue-update.timer
systemctl enable ublue-system-setup.service
systemctl enable ublue-guest-user.service
systemctl enable brew-setup.service
systemctl enable brew-upgrade.timer
systemctl enable brew-update.timer
systemctl --global enable ublue-user-setup.service
systemctl --global enable podman-auto-update.timer
systemctl enable check-sb-key.service
systemctl enable snap-symlink.service
systemctl disable waydroid-container.service
systemctl enable waydroid-workaround.service
systemctl enable etckeeper.timer
systemctl enable coolercontrold.service
systemctl enable flatpak-cleanup.timer
systemctl enable hwclock-sync.service
systemctl enable snapper-setup
systemctl enable keyd
systemctl disable displaylink.service

# Hide Desktop Files. Hidden removes mime associations
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/fish.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop

# Disable all COPRs and RPM Fusion Repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/firefoxpwa.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/terra.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
for i in /etc/yum.repos.d/rpmfusion-*; do
	sed -i 's@enabled=1@enabled=0@g' "${i}"
done

if [[ -f /etc/yum.repos.d/fedora-coreos-pool.repo ]]; then
	sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-coreos-pool.repo
fi

# Initialize etckeeper
etckeeper init
etckeeper commit "Initial base setup"
