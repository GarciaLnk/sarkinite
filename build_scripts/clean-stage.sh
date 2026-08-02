#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# this invalidates libdnf5 package
rm -rf /usr/lib/sysimage/libdnf5/*

# Upstream ublue-os-signing bug, we are using /usr/etc for the container signing and bootc gets mad at this
# FIXME: remove this once https://github.com/ublue-os/packages/issues/245 is closed
if [[ -d /usr/etc ]]; then
	cp -avf /usr/etc/. /etc
	rm -rvf /usr/etc
fi

# Relink rpm-ostree-base-db to rpmdb to ensure it correctly reflects the system
# image's rpmdb and doesn't carry over package info from the base image.
# See: https://github.com/coreos/rpm-ostree/issues/4554
# https://forge.fedoraproject.org/atomic/tracker/issues/82
for file in rpmdb.sqlite rpmdb.sqlite-shm rpmdb.sqlite-wal; do
    target="/usr/share/rpm/${file}"
    link_path="/usr/lib/sysimage/rpm-ostree-base-db/${file}"
    if [[ -f "${target}" && -f "${link_path}" ]]; then
        # Note, this needs to be a hardlink, not a symbolic link.
        ln -f "${target}" "${link_path}"
    fi
done

# shellcheck disable=SC2114
rm -rf /tmp/* \
	/var/tmp/* \
	/var/lib/{dnf,rhsm} \
	/var/cache/* \
	/boot

mkdir -p /boot

# Things we can't delete here are mounts from podman
find /var/* -maxdepth 0 -type d \! -name cache -exec rm -fr {} \;

find /run -mindepth 1 \
  ! -path '/run/systemd' \
  ! -path '/run/systemd/resolve' \
  ! -path '/run/systemd/resolve/stub-resolv.conf' \
  ! -path '/run/secrets' \
  ! -path '/run/secrets/*' \
  ! -path '/run/.containerenv' \
  -delete

bootc container lint --fatal-warnings --no-truncate

echo "::endgroup::"
