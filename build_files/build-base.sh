#!/usr/bin/env bash

set -eou pipefail

echo "::group:: Copy Files"
# Copy Files to Container
rsync -rvK /ctx/system_files/ /
echo "::endgroup::"

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Generate image-info.json
/ctx/build_files/00-image-info.sh

# Install Kernel and Akmods
/ctx/build_files/01-install-kernel-akmods.sh

# Install Additional Packages
/ctx/build_files/02-packages.sh

# Base Image Changes
/ctx/build_files/03-base-image-changes.sh

## late stage changes
# Systemd, Remove Items and Regenerate initramfs
/ctx/build_files/10-cleanup.sh

# Clean Up
echo "::group:: Cleanup"
/ctx/build_files/clean-stage.sh
mkdir -p /var/tmp &&
	chmod -R 1777 /var/tmp
ostree container commit
echo "::endgroup::"
