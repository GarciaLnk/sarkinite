#!/usr/bin/env bash
if test "$(id -u)" -gt "0" && test -d "${HOME}"; then
	# Add default settings when there are no settings
	if test ! -e "${HOME}"/.config/ghostty/config; then
		mkdir -p "${HOME}"/.config/ghostty
		cp -f /etc/skel/.config/ghostty/config "${HOME}"/.config/ghostty/config
	fi
fi
