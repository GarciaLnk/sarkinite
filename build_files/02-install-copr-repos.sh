#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# ublue-os staging
curl --retry 3 -Lo /etc/yum.repos.d/_copr_ublue-os-staging.repo https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo

# ublue-os packages
curl --retry 3 -Lo /etc/yum.repos.d/_copr_ublue-os-packages.repo https://copr.fedorainfracloud.org/coprs/ublue-os/packages/repo/fedora-"${FEDORA_MAJOR_VERSION}"/ublue-os-packages-fedora-"${FEDORA_MAJOR_VERSION}".repo

# disable negativo17-fedora-multimedia
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# Add ROM Properties
curl --retry 3 -Lo /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-rom-properties-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add Webapp Manager
curl --retry 3 -Lo /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-webapp-manager-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add FirefoxPWA
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

# Add Terra repos
curl --retry 3 -Lo /etc/yum.repos.d/terra.repo https://raw.githubusercontent.com/terrapkg/packages/refs/heads/f"${FEDORA_MAJOR_VERSION}"/anda/terra/release/terra.repo
curl --retry 3 -Lo /etc/yum.repos.d/terra-extras.repo https://raw.githubusercontent.com/terrapkg/packages/refs/heads/f"${FEDORA_MAJOR_VERSION}"/anda/terra/release/terra-extras.repo

# Add Sunshine repo
curl --retry 3 -Lo /etc/yum.repos.d/_copr_lizardbyte-stable.repo https://copr.fedorainfracloud.org/coprs/lizardbyte/stable/repo/fedora-"${FEDORA_MAJOR_VERSION}"/lizardbyte-stable-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Kvmfr module
curl --retry 3 -Lo /etc/yum.repos.d/_copr_hikariknight-looking-glass-kvmfr.repo \
	https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-"${FEDORA_MAJOR_VERSION}"/_copr_hikariknight-looking-glass-kvmfr.repo

echo "::endgroup::"
