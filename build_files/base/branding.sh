#!/usr/bin/bash

set -ouex pipefail

# Branding for Sarkinite
if test "${BASE_IMAGE_NAME}" = "silverblue"; then
	sed -i '/^PRETTY_NAME/s/Silverblue/Sarkinite/' /usr/lib/os-release
elif test "${BASE_IMAGE_NAME}" = "kinoite"; then
	sed -i '/^PRETTY_NAME/s/Kinoite/Sarkinite/' /usr/lib/os-release
fi
