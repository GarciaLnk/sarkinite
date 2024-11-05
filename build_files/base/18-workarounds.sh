#!/bin/sh
# shellcheck disable=SC2016

set -eoux pipefail

# alternatives cannot create symlinks on its own during a container build
if [ -f /usr/bin/ld.bfd ]; then
	ln -sf /usr/bin/ld.bfd /etc/alternatives/ld && ln -sf /etc/alternatives/ld /usr/bin/ld
fi

# Patch btrfs-assistant-launcher to not pass $XDG_RUNTIME_DIR so that it does not break flatpaks
sed -i 's/ --xdg-runtime=\\"${XDG_RUNTIME_DIR}\\"//g' /usr/bin/btrfs-assistant-launcher
