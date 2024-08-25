#!/usr/bin/bash

set -ouex pipefail

if [[ ${BASE_IMAGE_NAME} == "kinoite" ]]; then
	sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/org.kde.konsole.desktop
	rm -f /etc/profile.d/gnome-ssh-askpass.{csh,sh} # This shouldn't be pulled in
	rm -f /usr/share/kglobalaccel/org.kde.konsole.desktop
	systemctl enable kde-sysmonitor-workaround.service
fi
