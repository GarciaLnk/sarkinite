#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Upstream ublue-os-signing bug, we are using /usr/etc for the container signing and bootc gets mad at this
# FIXME: remove this once https://github.com/ublue-os/packages/issues/245 is closed
if [[ -d /usr/etc ]]; then
	cp -avf /usr/etc/. /etc
	rm -rvf /usr/etc
fi

# shellcheck disable=SC2114
rm -rf /.gitkeep \
	/var/tmp/* \
	/var/lib/{dnf,rhsm} \
	/var/cache/* \
	/boot

mkdir -p /boot

find /var/log -type f -exec bash -c '[ -s "$1" ] && rm "$1"' _ {} \;
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;

bootc container lint

echo "::endgroup::"
