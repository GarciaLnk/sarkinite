#!/usr/bin/bash

set -ouex pipefail

# Tela Icon Theme
git clone https://github.com/vinceliuice/Tela-icon-theme.git /tmp/tela-icon-theme
cd /tmp/tela-icon-theme || exit
./install.sh -c

# Fluent GTK Theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme /tmp/fluent-gtk-theme
cd /tmp/fluent-gtk-theme || exit
./install.sh -s compact -i fedora -l

if test "${BASE_IMAGE_NAME}" = "kinoite"; then
	# Fluent KDE Theme
	git clone https://github.com/vinceliuice/Fluent-kde /tmp/fluent-kde
	cd /tmp/fluent-kde || exit
	./install.sh -c
	rm -rf /usr/share/plasma/look-and-feel/com.github.vinceliuice.Fluent*
	rm -rf /usr/share/plasma/plasmoids/org.kde.plasma.splitdigitalclock
fi
