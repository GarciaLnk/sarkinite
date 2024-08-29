#!/usr/bin/bash

set -ouex pipefail

if [[ ${BASE_IMAGE_NAME} == "kinoite" ]]; then
	sed -i '/<entry name="launchers" type="StringList">/,/<\/entry>/ s/<default>[^<]*<\/default>/<default>preferred:\/\/filemanager,preferred:\/\/browser<\/default>/' /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
	rm -f /etc/profile.d/gnome-ssh-askpass.{csh,sh} # This shouldn't be pulled in
	systemctl enable kde-sysmonitor-workaround.service
fi
