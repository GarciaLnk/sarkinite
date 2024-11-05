#!/usr/bin/bash

set -eoux pipefail

# Add Staging repo
curl -Lo /etc/yum.repos.d/ublue-os-staging-fedora-"$(rpm -E %fedora)".repo \
	https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-"$(rpm -E %fedora)"/ublue-os-staging-fedora-"$(rpm -E %fedora)".repo

# Add Switcheroo Repo
curl -Lo /etc/yum.repos.d/_copr_sentry-switcheroo-control_discrete.repo \
	https://copr.fedorainfracloud.org/coprs/sentry/switcheroo-control_discrete/repo/fedora-"$(rpm -E %fedora)"/sentry-switcheroo-control_discrete-fedora-"$(rpm -E %fedora)".repo

# Add Nerd Fonts Repo
curl -Lo /etc/yum.repos.d/_copr_che-nerd-fonts-"$(rpm -E %fedora)".repo https://copr.fedorainfracloud.org/coprs/che/nerd-fonts/repo/fedora-"$(rpm -E %fedora)"/che-nerd-fonts-fedora-"$(rpm -E %fedora)".repo

# Add ROM Properties
curl -Lo /etc/yum.repos.d/_copr_kylegospo-rom-properties.repo https://copr.fedorainfracloud.org/coprs/kylegospo/rom-properties/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-rom-properties-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add Webapp Manager
curl -Lo /etc/yum.repos.d/_copr_kylegospo-webapp-manager.repo https://copr.fedorainfracloud.org/coprs/kylegospo/webapp-manager/repo/fedora-"${FEDORA_MAJOR_VERSION}"/kylegospo-webapp-manager-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add etckeeper
if [[ ${FEDORA_MAJOR_VERSION} -lt "41" ]]; then
	curl -Lo /etc/yum.repos.d/_copr_garcia-etckeeper.repo https://copr.fedorainfracloud.org/coprs/garcia/etckeeper/repo/fedora-"${FEDORA_MAJOR_VERSION}"/garcia-etckeeper-fedora-"${FEDORA_MAJOR_VERSION}".repo
fi

# Add CoolerControl
curl -Lo /etc/yum.repos.d/_copr_codifryed-CoolerControl.repo https://copr.fedorainfracloud.org/coprs/codifryed/CoolerControl/repo/fedora-"${FEDORA_MAJOR_VERSION}"/codifryed-CoolerControl-fedora-"${FEDORA_MAJOR_VERSION}".repo

# Add FirefoxPWA
echo -e "[firefoxpwa]\nname=FirefoxPWA\nmetadata_expire=300\nbaseurl=https://packagecloud.io/filips/FirefoxPWA/rpm_any/rpm_any/\$basearch\ngpgkey=https://packagecloud.io/filips/FirefoxPWA/gpgkey\nrepo_gpgcheck=1\ngpgcheck=0\nenabled=1" | tee /etc/yum.repos.d/firefoxpwa.repo

# Add keyd
curl -Lo /etc/yum.repos.d/_copr_alternateved-keyd.repo https://copr.fedorainfracloud.org/coprs/alternateved/keyd/repo/fedora-"${FEDORA_MAJOR_VERSION}"/alternateved-keyd-fedora-"${FEDORA_MAJOR_VERSION}".repo
