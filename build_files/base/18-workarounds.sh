#!/bin/sh
# shellcheck disable=SC2016

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# alternatives cannot create symlinks on its own during a container build
if [ -f /usr/bin/ld.bfd ]; then
	ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && ln -sf /etc/alternatives/ld /usr/bin/ld
fi

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

# Copy flatpak list on image to compare against it on boot wo/ requiring curl to gh
if [[ ${IMAGE_NAME} =~ "gnome" ]]; then
	FLATPAKS="flatpaks_gnome/flatpaks"
elif [[ ${IMAGE_NAME} =~ "kde" ]]; then
	FLATPAKS="flatpaks_kde/flatpaks"
fi
FLATPAK_LIST=($(curl https://raw.githubusercontent.com/GarciaLnk/sarkinite/main/${FLATPAKS}))
if [[ ${IMAGE_NAME} =~ "dx" ]]; then
	FLATPAK_LIST+=($(curl https://raw.githubusercontent.com/GarciaLnk/sarkinite/main/dx_flatpaks/flatpaks))
fi
printf "%s\n" "${FLATPAK_LIST[@]}" > /usr/share/ublue-os/flatpak-list

echo "::endgroup::"
