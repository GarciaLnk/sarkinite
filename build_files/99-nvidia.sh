#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

## nvidia install steps
rpm-ostree install /tmp/akmods-rpms/ublue-os/ublue-os-nvidia-addons-*.rpm

# enable repo provided by ublue-os-nvidia-addons
sed -i '0,/enabled=0/{s/enabled=0/enabled=1/}' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Enable staging for supergfxctl
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo

# Enable fedora-nvidia
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

source /tmp/akmods-rpms/kmods/nvidia-vars

rpm-ostree override replace \
	--experimental \
	--from repo=fedora-multimedia \
	mesa-dri-drivers \
	mesa-filesystem \
	mesa-libEGL \
	mesa-libGL \
	mesa-libgbm \
	mesa-libglapi \
	mesa-libxatracker \
	mesa-va-drivers \
	mesa-vulkan-drivers ||
	true

rpm-ostree install \
	libnvidia-fbc \
	libnvidia-ml \
	libva-nvidia-driver \
	nvidia-driver \
	nvidia-driver-cuda \
	nvidia-driver-cuda-libs \
	nvidia-driver-libs \
	nvidia-settings \
	nvidia-container-toolkit \
	/tmp/akmods-rpms/kmods/kmod-nvidia-"${KERNEL_VERSION}"-"${NVIDIA_AKMOD_VERSION}".fc"${RELEASE}".rpm

rpm-ostree install supergfxctl-plasmoid supergfxctl prime-run

## nvidia post-install steps
# disable repo provided by ublue-os-nvidia-addons
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/nvidia-container-toolkit.repo

# Disable staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-staging.repo

# disable fedora-nvidia
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-nvidia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

# ensure kernel.conf matches NVIDIA_FLAVOR (which must be nvidia or nvidia-open)
# kmod-nvidia-common defaults to 'nvidia-open' but this will match our akmod image
sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=${KERNEL_MODULE_TYPE}/" /etc/nvidia/kernel.conf

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
