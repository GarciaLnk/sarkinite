#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

#ublue-os staging
curl --retry 3 -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo \
	https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Kvmfr module
curl --retry 3 -Lo /etc/yum.repos.d/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo \
	https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/hikariknight-looking-glass-kvmfr-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Enable terra repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/terra.repo

echo "::endgroup::"
