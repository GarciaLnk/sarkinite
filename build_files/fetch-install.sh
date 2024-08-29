#!/usr/bin/bash

set -ouex pipefail

# Starship Shell Prompt
curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"
tar -xzf /tmp/starship.tar.gz -C /tmp
install -c -m 0755 /tmp/starship /usr/bin
# shellcheck disable=SC2016
echo 'eval "$(starship init bash)"' >>/etc/bashrc

# Bash Prexec
curl -Lo /usr/share/bash-prexec https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh

# Topgrade Install
pip install --prefix=/usr topgrade

# Install ublue-update -- breaks with packages.json disable staging to use bling.
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo
rpm-ostree install ublue-update

# Consolidate Just Files
find /tmp/just -iname '*.just' -exec printf "\n\n" \; -exec cat {} \; >>/usr/share/ublue-os/just/60-custom.just

# Move over ublue-update config
mv -f /tmp/ublue-update.toml /usr/etc/ublue-update/ublue-update.toml

# Waydroid
sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh
curl -Lo /usr/bin/waydroid-choose-gpu https://raw.githubusercontent.com/KyleGospo/waydroid-scripts/main/waydroid-choose-gpu.sh
chmod +x /usr/bin/waydroid-choose-gpu
if [[ -f "/var/lib/waydroid/lxc/waydroid/config" ]]; then
	sed -i '/lxc\.apparmor\.profile\s*=\s*unconfined/d' "/var/lib/waydroid/lxc/waydroid/config"
fi

# Cloudflare WARP Plasmoid
if test "${BASE_IMAGE_NAME}" = "kinoite"; then
	git clone https://github.com/korapp/plasma-cloudflare-warp.git /tmp/plasma-cloudflare-warp
	cd /tmp/plasma-cloudflare-warp
	kpackagetool6 -i package
	rm -rf /tmp/plasma-cloudflare-warp
fi

# Pull in just recipes
curl -Lo /usr/share/ublue-os/just/82-waydroid.just https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/usr/share/ublue-os/just/82-bazzite-waydroid.just
curl -Lo /usr/share/ublue-os/just/83-audio.just https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/usr/share/ublue-os/just/83-bazzite-audio.just
