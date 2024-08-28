#!/usr/bin/bash

set -ouex pipefail

if [[ ${BASE_IMAGE_NAME} == "kinoite" ]]; then
	rm -f /etc/profile.d/gnome-ssh-askpass.{csh,sh} # This shouldn't be pulled in
	systemctl enable kde-sysmonitor-workaround.service
fi
