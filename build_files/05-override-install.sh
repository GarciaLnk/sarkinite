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

# Install ublue packages
dnf5 -y copr enable ublue-os/staging
dnf5 -y install devpod yafti
dnf5 -y copr disable ublue-os/staging

# Waydroid
sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh
if [[ -f "/var/lib/waydroid/lxc/waydroid/config" ]]; then
	sed -i '/lxc\.apparmor\.profile\s*=\s*unconfined/d' "/var/lib/waydroid/lxc/waydroid/config"
fi

echo "::endgroup::"
