#!/usr/bin/env bash

set -eou pipefail

echo "::group:: Copy Files"

# there is no 'rpm-ostree cliwrap uninstall-from-root', but this is close enough. See:
# https://github.com/coreos/rpm-ostree/blob/6d2548ddb2bfa8f4e9bafe5c6e717cf9531d8001/rust/src/cliwrap.rs#L25-L32
if [[ -d /usr/libexec/rpm-ostree/wrapped ]]; then
	# binaries which could be created if they did not exist thus may not be in wrapped dir
	rm -f \
		/usr/bin/yum \
		/usr/bin/dnf \
		/usr/bin/kernel-install
	# binaries which were wrapped
	mv -f /usr/libexec/rpm-ostree/wrapped/* /usr/bin
	rm -fr /usr/libexec/rpm-ostree
fi

# Copy Files to Container
cp -r /ctx/just /tmp/just
cp /ctx/packages /tmp/packages
rsync -rvK /ctx/system_files/ /
echo "::endgroup::"

# Apply IP Forwarding before installing Docker to prevent messing with LXC networking
sysctl -p

# Generate image-info.json
/ctx/build_files/00-image-info.sh

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
/ctx/build_files/clean-stage.sh
mkdir -p /var/tmp &&
	chmod -R 1777 /var/tmp
ostree container commit
echo "::endgroup::"
