#!/usr/bin/env bash

set -eou pipefail

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Generate image-info.json
/var/tmp/build_scripts/00-image-info.sh

# Install Kernel and Akmods
/var/tmp/build_scripts/01-install-kernel-akmods.sh

# Install Additional Packages
/var/tmp/build_scripts/02-packages.sh

# Base Image Changes
/var/tmp/build_scripts/03-base-image-changes.sh

## late stage changes
# Systemd, Remove Items and Regenerate initramfs
/var/tmp/build_scripts/10-cleanup.sh

# Simple Tests, shared with the base
/var/tmp/build_scripts/20-tests.sh

# Clean Up
echo "::group:: Cleanup"
/var/tmp/build_scripts/clean-stage.sh

echo "::endgroup::"
