#!/usr/bin/bash

set -ouex pipefail

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
systemctl enable snap-symlink.service
systemctl disable waydroid-container.service
systemctl enable waydroid-workaround.service
systemctl enable etckeeper.timer
systemctl enable coolercontrold.service
systemctl enable flatpak-cleanup.timer
systemctl enable hwclock-sync.service
systemctl enable check-sb-key.service
systemctl enable snapper-setup
systemctl enable keyd
