#!/usr/bin/env bash

if test "$(id -u)" -gt "0" && test -d "${HOME}"; then
	if test ! -e "${HOME}"/.config/autostart/sarkinite-firstboot.desktop; then
		mkdir -p "${HOME}"/.config/autostart
		cp -f /etc/skel/.config/autostart/sarkinite-firstboot.desktop "${HOME}"/.config/autostart
	fi
fi
