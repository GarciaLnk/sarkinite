#!/usr/bin/env bash
# shellcheck disable=SC2068,SC2207,SC2046

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# build list of all packages requested for inclusion
INCLUDED_PACKAGES=($({ grep '^\+' /tmp/packages || true; } | sed 's/^+//'))

# build list of all packages requested for exclusion
EXCLUDED_PACKAGES=($({ grep '^-' /tmp/packages || true; } | sed 's/^-//'))

# store a list of RPMs installed on the image
INSTALLED_EXCLUDED_PACKAGES=()

# ensure exclusion list only contains packages already present on image
if [[ ${#EXCLUDED_PACKAGES[@]} -gt 0 ]]; then
	INSTALLED_EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

# remove excluded packages
if [[ ${#EXCLUDED_PACKAGES[@]} -gt 0 ]]; then
	dnf5 -y remove \
		${EXCLUDED_PACKAGES[@]}
fi

# install included packages
if [[ ${#INCLUDED_PACKAGES[@]} -gt 0 ]]; then
	dnf5 -y install \
		${INCLUDED_PACKAGES[@]}
fi

# check if any excluded packages are still present
# (this can happen if an included package pulls in a dependency)
if [[ ${#EXCLUDED_PACKAGES[@]} -gt 0 ]]; then
	INSTALLED_EXCLUDED_PACKAGES=($(rpm -qa --queryformat='%{NAME} ' ${EXCLUDED_PACKAGES[@]}))
fi

# remove any excluded packages which are still present on image
if [[ ${#INSTALLED_EXCLUDED_PACKAGES[@]} -gt 0 ]]; then
	dnf5 -y remove \
		${INSTALLED_EXCLUDED_PACKAGES[@]}
fi

echo "::endgroup::"
