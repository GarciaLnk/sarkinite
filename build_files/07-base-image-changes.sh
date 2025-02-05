#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Tela Icon Theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme
cd /tmp/tela-icon-theme || exit
./install.sh -c

# Fluent GTK Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme /tmp/fluent-gtk-theme
cd /tmp/fluent-gtk-theme || exit
./install.sh -s compact -l

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

# Get Default Font since font fallback doesn't work
curl --retry 3 --output-dir /tmp -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip
mkdir -p /usr/share/fonts/fira-nf
unzip /tmp/FiraCode.zip -d /usr/share/fonts/fira-nf
fc-cache -f /usr/share/fonts/fira-nf

# Fluent KDE Theme
git clone https://github.com/vinceliuice/Fluent-kde /tmp/fluent-kde
cd /tmp/fluent-kde || exit
./install.sh -c
rm -rf /usr/share/plasma/look-and-feel/com.github.vinceliuice.Fluent*
rm -rf /usr/share/plasma/plasmoids/org.kde.plasma.splitdigitalclock

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
	cat <<EOF >/tmp/just/95-nvidia.just
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
