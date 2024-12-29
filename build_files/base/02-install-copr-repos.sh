#!/usr/bin/bash

set -eoux pipefail

# Add Staging repo
curl --retry 3 -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"$(rpm -E %fedora)".repo \
	https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"$(rpm -E %fedora)"/ublue-os-staging-fedora-"$(rpm -E %fedora)".repo

# Add Switcheroo Repo
curl --retry 3 -Lo /etc/yum.repos.d/_copr_sentry-switcheroo-control_discrete.repo \
	https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/repo/fedora-"$(rpm -E %fedora)"/sentry-switcheroo-control_discrete-fedora-"$(rpm -E %fedora)".repo

# Add ROM Properties
curl --retry 3 -Lo /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-rom-properties-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add Webapp Manager
curl --retry 3 -Lo /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-webapp-manager-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add FirefoxPWA
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

# Add Terra repo
curl --retry 3 -Lo /etc/yum.repos.d/terra.repo https://raw.githubusercontent.com/terrapkg/subatomic-repos/main/terra.repo

# Add Sunshine repo
curl --retry 3 -Lo /etc/yum.repos.d/_copr_matte-schwartz-sunshine.repo https://copr.fedorainfracloud.org/coprs/matte-schwartz/sunshine/repo/fedora-"${FEDORA_MAJOR_VERSION}"/matte-schwartz-sunshine-fedora-"${FEDORA_MAJOR_VERSION}".repo
