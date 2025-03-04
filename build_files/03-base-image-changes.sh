#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Modify Firefox .desktop to use wrapper
sed -i 's@Exec=firefox@Exec=/usr/bin/firefox-wrapper@g' /usr/share/applications/org.mozilla.firefox.desktop

# mpv tweaks
curl --retry 3 -Lo /tmp/uosc-install.sh https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh
MPV_CONFIG_DIR=/etc/mpv bash /tmp/uosc-install.sh
curl --retry 3 -Lo /etc/mpv/scripts/thumbfast.lua https://raw.githubusercontent.com/po5/thumbfast/refs/heads/master/thumbfast.lua
curl --retry 3 -Lo /etc/mpv/scripts/SmartCopyPaste_II.lua https://raw.githubusercontent.com/Eisa01/mpv-scripts/refs/heads/master/scripts/SmartCopyPaste_II.lua

# SDDM wallpaper
ln -sf /usr/share/wallpapers/Kay/contents/images_dark/5120x2880.png /usr/share/backgrounds/default.png
ln -sf /usr/share/wallpapers/Kay/contents/images_dark/5120x2880.png /usr/share/backgrounds/default-dark.png

# Favorites in Kickoff
sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/filemanager,preferred:\/\/browser<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml

# Fix caps
setcap 'cap_net_raw+ep' /usr/libexec/ksysguard/ksgrd_network_helper
setcap 'cap_sys_admin+p' "$(readlink -f "$(command -v sunshine)")"

# Waydroid
sed -i~ -E 's/=.\$\(command -v (nft|ip6?tables-legacy).*/=/g' /usr/lib/waydroid/data/scripts/waydroid-net.sh
if [[ -f "/var/lib/waydroid/lxc/waydroid/config" ]]; then
	sed -i '/lxc\.apparmor\.profile\s*=\s*unconfined/d' "/var/lib/waydroid/lxc/waydroid/config"
fi

# Nvidia Configurations
if [[ ${IMAGE_NAME} =~ "nvidia" ]]; then
	# Disable GSP on -nvidia builds
	cat <<EOF >/usr/lib/modprobe.d/nvidia-gsp-workaround.conf
options nvidia NVreg_EnableGpuScreenPreemption=0
EOF

	# Firefox Nvidia config
	cat <<EOF >/usr/lib64/firefox/defaults/pref/00-sarkinite-nvidia.js
pref("widget.dmabuf.force-enabled", true);
EOF

	# Nvidia Just commands
	cat <<EOF >/usr/share/ublue-os/just/95-nvidia.just
enable-supergfxctl:
systemctl enable --now supergfxd.service
EOF

	# Add udev rules to workaround NVML error (https://github.com/NVIDIA/nvidia-container-toolkit/issues/48)
	cat <<EOF >/etc/udev/rules.d/71-nvidia-dev-char.rules
ACTION=="add", DEVPATH=="/bus/pci/drivers/nvidia", RUN+="/usr/bin/nvidia-ctk system 	create-dev-char-symlinks --create-all"
EOF

	# Set nvidia-container-runtime in docker daemon.json
	mkdir -p /etc/docker
	cat <<EOF >/etc/docker/daemon.json
{
    "runtimes": {
        "nvidia": {
            "args": [],
            "path": "nvidia-container-runtime"
        }
    }
}
EOF

fi

echo "::endgroup::"
