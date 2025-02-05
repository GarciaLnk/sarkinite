#!/usr/bin/env bash
# shellcheck disable=SC2016

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# alternatives cannot create symlinks on its own during a container build
if [[ -f /usr/bin/ld.bfd ]]; then
	ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && ln -sf /etc/alternatives/ld /usr/bin/ld
fi

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

# Copy flatpak list on image to compare against it on boot wo/ requiring curl to gh
mapfile -t FLATPAK_LIST </ctx/flatpaks
printf "%s\n" "${FLATPAK_LIST[@]}" >/usr/share/ublue-os/flatpak-list

echo "::endgroup::"
