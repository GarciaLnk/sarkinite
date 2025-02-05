#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Patched shells
rpm-ostree override replace \
	--experimental \
	--from repo=terra-extras \
	kf6-kio-doc \
	kf6-kio-widgets-libs \
	kf6-kio-core-libs \
	kf6-kio-widgets \
	kf6-kio-file-widgets \
	kf6-kio-core \
	kf6-kio-gui

# Switcheroo patch
rpm-ostree override replace \
	--experimental \
	--from repo=terra-extras \
	switcheroo-control

# Flahub repo
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Install ublue packages
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo
rpm-ostree install devpod ublue-brew yafti ublue-update
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo

# Consolidate Just Files
find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >>/usr/share/ublue-os/just/60-custom.just

# Move over ublue-update config
mv -f /tmp/ublue-update.toml /usr/etc/ublue-update/ublue-update.toml

# Register Fonts
fc-cache -f /usr/share/fonts/ubuntu
fc-cache -f /usr/share/fonts/inter

# Waydroid
sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh
curl --retry 3 -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh
chmod +x /usr/bin/waydroid-choose-gpu
if [[ -f "/var/lib/waydroid/lxc/waydroid/config" ]]; then
	sed -i '/lxc\.apparmor\.profile\s*=\s*unconfined/d' "/var/lib/waydroid/lxc/waydroid/config"
fi

# pkgx
curl --retry 3 -Lo ./pkgx "https://pkgx.sh/$(uname)/$(uname -m)"
chmod +x ./pkgx
mv ./pkgx /usr/bin/pkgx

# ls-iommu helper tool for listing devices in iommu groups (PCI Passthrough)
DOWNLOAD_URL=$(curl https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest | jq -r '.assets[] | select(.name| test(".*x86_64.tar.gz$")).browser_download_url')
curl --retry 3 -Lo /tmp/ls-iommu.tar.gz "${DOWNLOAD_URL}"
mkdir /tmp/ls-iommu
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu
mv /tmp/ls-iommu/ls-iommu /usr/bin/
rm -rf /tmp/ls-iommu*

echo "::endgroup::"
