#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Patched shells
dnf5 -y swap \
	--repo=terra-extras \
	kf6-kio kf6-kio

# Make sure KDE Frameworks and our kf6-kio are on the same version
kf6_version=$(rpm -qi kf6-kcoreaddons | awk '/^Version/ {print $3}')
kf6_kio_version=$(rpm -qi kf6-kio-core | awk '/^Version/ {print $3}')

if [[ ${kf6_version} != "${kf6_kio_version}" ]]; then
	echo "Mismatched kf6-kio version ${kf6_kio_version}."
	exit 1
fi

# Switcheroo patch
dnf5 -y swap \
	--repo=terra-extras \
	switcheroo-control switcheroo-control

# Flahub repo
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Install ublue packages
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod yafti
dnf5 -y copr disable ublue-os/staging

# Consolidate Just Files
find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >>/usr/share/ublue-os/just/60-custom.just

# Waydroid
sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh
curl --retry 3 -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh
chmod +x /usr/bin/waydroid-choose-gpu
if [[ -f "/var/lib/waydroid/lxc/waydroid/config" ]]; then
	sed -i '/lxc\.apparmor\.profile\s*=\s*unconfined/d' "/var/lib/waydroid/lxc/waydroid/config"
fi

# ls-iommu helper tool for listing devices in iommu groups (PCI Passthrough)
DOWNLOAD_URL=$(curl https://api.github.com/repos/HikariKnight/ls-iommu/releases/latest | jq -r '.assets[] | select(.name| test(".*x86_64.tar.gz$")).browser_download_url')
curl --retry 3 -Lo /tmp/ls-iommu.tar.gz "${DOWNLOAD_URL}"
mkdir /tmp/ls-iommu
tar --no-same-owner --no-same-permissions --no-overwrite-dir -xvzf /tmp/ls-iommu.tar.gz -C /tmp/ls-iommu
mv /tmp/ls-iommu/ls-iommu /usr/bin/
rm -rf /tmp/ls-iommu*

echo "::endgroup::"
