#!/usr/bin/bash

set -ouex pipefail

# Tela Icon Theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme
cd /tmp/tela-icon-theme || exit
./install.sh -c

# Fluent GTK Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme /tmp/fluent-gtk-theme
cd /tmp/fluent-gtk-theme || exit
./install.sh -s compact -l

if [[ ${BASE_IMAGE_NAME} == "kinoite" ]]; then

	# Restore x11 for Nvidia Images
	if [[ ${FEDORA_MAJOR_VERSION} -eq "40" ]]; then
		rpm-ostree install plasma-workspace-x11
	fi

	# SDDM wallpaper
	ln -sf /usr/share/wallpapers/Kay/contents/images_dark/5120x2880.png /usr/share/backgrounds/default.png
	ln -sf /usr/share/wallpapers/Kay/contents/images_dark/5120x2880.png /usr/share/backgrounds/default-dark.png

	# Favorites in Kickoff
	sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/filemanager,preferred:\/\/browser<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml

	rm -f /etc/profile.d/gnome-ssh-askpass.{csh,sh} # This shouldn't be pulled in
	systemctl enable kde-sysmonitor-workaround.service

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

elif [[ ${BASE_IMAGE_NAME} == "silverblue" ]]; then

	# Remove desktop entries
	if [[ -f /usr/share/applications/gnome-system-monitor.desktop ]]; then
		sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/gnome-system-monitor.desktop
	fi
	if [[ -f /usr/share/applications/org.gnome.SystemMonitor.desktop ]]; then
		sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/org.gnome.SystemMonitor.desktop
	fi

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
	cat <<EOF >/tmp/just/95-nvidia.just
enable-supergfxctl:
systemctl enable --now supergfxd.service
EOF

	# Use OpenGL renderer for GSK
	if [[ ${FEDORA_MAJOR_VERSION} -eq "40" ]]; then
		cat <<EOF >/etc/environment.d/99-gsk-renderer-opengl.conf
GSK_RENDERER=ngl
EOF
	fi

fi
