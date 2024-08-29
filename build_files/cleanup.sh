#!/usr/bin/bash

set -ouex pipefail

# Hide Desktop Files. Hidden removes mime associations
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/fish.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/winetricks.desktop
sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop

# Disable all COPRs and RPM Fusion Repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/charm.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/ublue-os-bling-fedora-"${FEDORA_MAJOR_VERSION}".repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_che-nerd-fonts-"${FEDORA_MAJOR_VERSION}".repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_garcia-etckeeper.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/cloudflare-warp.repo
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
