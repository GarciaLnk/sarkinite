#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# dnf cleanup
dnf5 remove -y ostree-grub2
dnf5 autoremove -y
dnf5 clean all

# shellcheck disable=SC2114
rm -rf /.gitkeep \
	/var/tmp/* \
	/var/lib/{dnf,rhsm} \
	/var/cache/* \
	/boot

mkdir -p /boot

find /var/log -type f -exec bash -c '[ -s "$1" ] && rm "$1"' _ {} \;
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;

bootc container lint --fatal-warnings

echo "::endgroup::"
