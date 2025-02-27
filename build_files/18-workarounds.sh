#!/usr/bin/env bash
# shellcheck disable=SC2016

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher

# Copy flatpak list on image to compare against it on boot
mapfile -t FLATPAK_LIST </ctx/flatpaks
printf "%s\n" "${FLATPAK_LIST[@]}" >/usr/share/ublue-os/flatpak-list

echo "::endgroup::"
