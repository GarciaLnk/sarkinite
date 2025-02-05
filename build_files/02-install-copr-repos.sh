#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Add Terra repos
dnf5 -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_MAJOR_VERSION}" terra-release{,-extras}

# ublue-os packages
dnf5 -y copr enable ublue-os/packages

# disable negativo17-fedora-multimedia
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# Add ROM Properties
dnf5 -y copr enable kylegospo/rom-properties

# Add Webapp Manager
dnf5 -y copr enable kylegospo/webapp-manager

# Add FirefoxPWA
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

# Add Sunshine repo
dnf5 -y copr enable lizardbyte/stable

# Kvmfr module
dnf5 -y copr enable hikariknight/looking-glass-kvmfr

echo "::endgroup::"
