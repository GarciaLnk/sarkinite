#!/usr/bin/env bash
if test "$(id -u)" -gt "0" && test -d "${HOME}"; then
	# Add default settings when there are no settings
	if test ! -e "${HOME}"/.config/zed/settings.json; then
		mkdir -p "${HOME}"/.config/zed
		cp -f /etc/skel/.config/zed/settings.json "${HOME}"/.config/zed/settings.json
	fi
fi
