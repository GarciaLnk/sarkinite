#!/usr/bin/env bash

set -ouex pipefail

## nvidia install steps
dnf5 --repo=fedora,updates -y install /tmp/akmods-rpms/ublue-os/ublue-os-nvidia-addons-*.rpm

# shellcheck disable=SC1091
source /tmp/akmods-rpms/kmods/nvidia-vars

dnf5 --repo=fedora,updates,fedora-nvidia,nvidia-container-toolkit -y install \
	libnvidia-fbc \
	libnvidia-ml \
	libva-nvidia-driver \
	nvidia-driver \
	nvidia-driver-cuda \
	nvidia-driver-cuda-libs \
	nvidia-driver-libs \
	nvidia-settings \
	nvidia-container-toolkit \
	/tmp/akmods-rpms/kmods/kmod-nvidia-"${KERNEL_VERSION}"-"${NVIDIA_AKMOD_VERSION}"."${DIST_ARCH}".rpm

# Ensure the version of the Nvidia module matches the driver
KMOD_VERSION="$(rpm -q --queryformat '%{VERSION}' kmod-nvidia)"
DRIVER_VERSION="$(rpm -q --queryformat '%{VERSION}' nvidia-driver)"
if [[ ${KMOD_VERSION} != "${DRIVER_VERSION}" ]]; then
	echo "Error: kmod-nvidia version (${KMOD_VERSION}) does not match nvidia-driver version (${DRIVER_VERSION})"
	exit 1
fi

dnf5 --repofrompath=ublue-os-staging,https://download.copr.fedorainfracloud.org/results/ublue-os/staging/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=ublue-os-staging.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/staging/pubkey.gpg \
	--repo=fedora,updates,ublue-os-staging -y install \
	supergfxctl-plasmoid supergfxctl

dnf5 --repofrompath=terra,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}" \
	--setopt=terra.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"/key.asc \
	--repo=terra -y install \
	prime-run

dnf5 clean all

systemctl enable ublue-nvctk-cdi.service
semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp

# Universal Blue specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
# we must force driver load to fix black screen on boot for nvidia desktops
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
# as we need forced load, also mustpre-load intel/amd iGPU else chromium web browsers fail to use hardware acceleration
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
