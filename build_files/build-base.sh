#!/usr/bin/env bash

set -eou pipefail

echo "::group:: Copy Files"
# Make Alternatives Directory
mkdir -p /var/lib/alternatives

# Copy Files to Container
cp -r /ctx/just /tmp/just
cp /ctx/packages /tmp/packages
cp /ctx/system_files/etc/ublue-update/ublue-update.toml /tmp/ublue-update.toml
rsync -rvK /ctx/system_files/ /
echo "::endgroup::"

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Generate image-info.json
/ctx/build_files/00-image-info.sh

# Build Fix - Fix known skew offenders
/ctx/build_files/01-build-fix.sh

# Get COPR Repos
/ctx/build_files/02-install-copr-repos.sh

# Install Kernel and Akmods
/ctx/build_files/03-install-kernel-akmods.sh

# Install Additional Packages
/ctx/build_files/04-packages.sh

# Install Overrides and Fetch Install
/ctx/build_files/05-override-install.sh

# Base Image Changes
/ctx/build_files/07-base-image-changes.sh

# Get Firmare for Framework
/ctx/build_files/08-firmware.sh

# Install Brew
/ctx/build_files/10-brew.sh

## late stage changes

# Systemd and Remove Items
/ctx/build_files/17-cleanup.sh

# Run workarounds for lf (Likely not needed)
/ctx/build_files/18-workarounds.sh

# Regenerate initramfs
/ctx/build_files/19-initramfs.sh

# Clean Up
echo "::group:: Cleanup"
mv /var/lib/alternatives /staged-alternatives
/ctx/build_files/clean-stage.sh
mkdir -p /var/lib && mv /staged-alternatives /var/lib/alternatives &&
	mkdir -p /var/tmp &&
	chmod -R 1777 /var/tmp
ostree container commit
echo "::endgroup::"
