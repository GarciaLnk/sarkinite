#!/usr/bin/bash

set -eoux pipefail

# Patched shells
if [[ ${BASE_IMAGE_NAME} =~ silverblue ]]; then
	rpm-ostree override replace \
		--experimental \
		--from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
		gnome-shell
elif [[ ${BASE_IMAGE_NAME} =~ kinoite ]]; then
	rpm-ostree override replace \
		--experimental \
		--from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
		kf6-kio-doc \
		kf6-kio-widgets-libs \
		kf6-kio-core-libs \
		kf6-kio-widgets \
		kf6-kio-file-widgets \
		kf6-kio-core \
		kf6-kio-gui
fi

# GNOME Triple Buffering
if [[ ${BASE_IMAGE_NAME} =~ silverblue && ${FEDORA_MAJOR_VERSION} -lt "41" ]]; then
	rpm-ostree override replace \
		--experimental \
		--from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
		mutter \
		mutter-common
fi

# Fix for ID in fwupd
rpm-ostree override replace \
	--experimental \
	--from repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
	fwupd \
	fwupd-plugin-flashrom \
	fwupd-plugin-modem-manager \
	fwupd-plugin-uefi-capsule-data

# Switcheroo patch
rpm-ostree override replace \
	--experimental \
	--from repo=copr:copr.fedorainfracloud.org:sentry:switcheroo-control_discrete \
	switcheroo-control

rm /etc/yum.repos.d/_copr_sentry-switcheroo-control_discrete.repo

# Flahub repo
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# Install ublue-update -- breaks with packages.json due to missing topgrade
rpm-ostree install ublue-update

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
