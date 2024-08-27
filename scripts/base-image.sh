#!/usr/bin/bash
set -euo pipefail

image=$1

if [[ ${image} =~ "gnome" ]]; then
	echo silverblue
elif [[ ${image} =~ "kde" ]]; then
	echo kinoite
elif [[ ${image} =~ "sway" ]]; then
	echo sericea
else
	exit 1
fi
