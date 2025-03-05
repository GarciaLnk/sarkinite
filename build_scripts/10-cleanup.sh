#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Setup Systemd
systemctl enable tailscaled.service
systemctl enable dconf-update.service
systemctl --global enable ublue-flatpak-manager.service
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-system-update.timer
systemctl --global enable flatpak-user-update.timer
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
systemctl enable snapper-setup.service
systemctl enable keyd.service
systemctl enable usr-share-sddm-themes.mount
systemctl enable grub-boot-success.timer
systemctl enable grub-boot-success.service
systemctl --global enable p11-kit-server.socket
systemctl --global enable p11-kit-server.service
systemctl enable docker.socket
systemctl enable podman.socket
systemctl enable swtpm-workaround.service
systemctl enable libvirt-workaround.service
systemctl enable sarkinite-groups.service
systemctl enable --global sarkinite-user-vscode.service
systemctl enable docker-prune.timer

# systemd-remount-fs.service fails w/ btfs and composefs enabled
# track for F42: https://bugzilla.redhat.com/show_bug.cgi?id=2348934
systemctl mask systemd-remount-fs.service

# Enable polkit rules for fingerprint sensors via fprintd
authselect enable-feature with-fingerprint

# Disable all repos
dnf5 config-manager setopt "*.enabled=0"

# Hide Desktop Files. Hidden removes mime associations
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/htop.desktop
sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/nvtop.desktop
sed -i 's@Exec=waydroid first-launch@Exec=/usr/bin/waydroid-launcher first-launch\nX-Steam-Library-Capsule=/usr/share/applications/Waydroid/capsule.png\nX-Steam-Library-Hero=/usr/share/applications/Waydroid/hero.png\nX-Steam-Library-Logo=/usr/share/applications/Waydroid/logo.png\nX-Steam-Library-StoreCapsule=/usr/share/applications/Waydroid/store-logo.png\nX-Steam-Controller-Template=Desktop@g' /usr/share/applications/Waydroid.desktop

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
# shellcheck disable=SC2016
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
/usr/bin/dracut --no-hostonly --kver "${QUALIFIED_KERNEL}" --reproducible -v --add ostree -f "/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"
chmod 0600 "/lib/modules/${QUALIFIED_KERNEL}/initramfs.img"

echo "::endgroup::"
