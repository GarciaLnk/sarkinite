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

# Fluent KDE Theme
git clone https://github.com/vinceliuice/Fluent-kde /tmp/fluent-kde
cd /tmp/fluent-kde || exit
rm -rf plasma/look-and-feel/*
rm -rf plasma/plasmoids/org.kde.plasma.splitdigitalclock
./install.sh -c
