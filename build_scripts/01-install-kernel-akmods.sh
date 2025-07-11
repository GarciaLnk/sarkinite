#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Remove Existing Kernel
dnf5 -y remove kernel-{core,modules,modules-core,modules-extra,tools,tools-libs}

# Fetch Common AKMODS & Kernel RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"${AKMODS_TARGZ}" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/
# NOTE: kernel-rpms should auto-extract into correct location

# Install Kernel
dnf5 -y install /tmp/kernel-rpms/kernel{,-core,-modules,-modules-core,-modules-extra,-devel,-devel,-devel-matched}-"${KERNEL}".rpm kernel-{tools,tools-libs}-"${KERNEL}"
dnf5 -y remove kernel-tools{,-libs}

dnf5 versionlock add kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

# Everyone
dnf5 --repofrompath=ublue-os-akmods,https://download.copr.fedorainfracloud.org/results/ublue-os/akmods/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repofrompath=rpmfusion-free-updates,http://download1.rpmfusion.org/free/fedora/updates/"${FEDORA_MAJOR_VERSION}"/x86_64/ \
	--setopt=ublue-os-akmods.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/akmods/pubkey.gpg \
	--setopt=rpmfusion-free-updates.gpgkey="https://rpmfusion.org/keys?action=AttachFile&do=get&target=RPM-GPG-KEY-rpmfusion-free-fedora-2020" \
	--repo=fedora,updates,ublue-os-akmods,rpmfusion-free-updates -y install \
	v4l2loopback /tmp/akmods/kmods/*v4l2loopback*.rpm \
	/tmp/akmods/kmods/*xone*.rpm \
	/tmp/akmods/kmods/*openrazer*.rpm \
	/tmp/akmods/kmods/*framework-laptop*.rpm

dnf5 --repofrompath=hikariknight-looking-glass-kvmfr,https://download.copr.fedorainfracloud.org/results/hikariknight/looking-glass-kvmfr/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--setopt=hikariknight-looking-glass-kvmfr.gpgkey=https://download.copr.fedorainfracloud.org/results/hikariknight/looking-glass-kvmfr/pubkey.gpg \
	--repo=fedora,updates,hikariknight-looking-glass-kvmfr -y install \
	/tmp/akmods/kmods/*kvmfr*.rpm

# Nvidia AKMODS
if [[ ${IMAGE_NAME} =~ nvidia ]]; then
	# Fetch Nvidia RPMs
	skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-nvidia-open:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods-rpms
	NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json | cut -d : -f 2)
	tar -xvzf /tmp/akmods-rpms/"${NVIDIA_TARGZ}" -C /tmp/
	mv /tmp/rpms/* /tmp/akmods-rpms/

	# Install Nvidia RPMs
	/var/tmp/build_scripts/99-nvidia.sh
	rm -f /usr/share/vulkan/icd.d/nouveau_icd.*.json
	ln -sf libnvidia-ml.so.1 /usr/lib64/libnvidia-ml.so
fi

# Fetch ZFS RPMs
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-zfs:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods-zfs
ZFS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-zfs/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods-zfs/"${ZFS_TARGZ}" -C /tmp/
mv /tmp/rpms/* /tmp/akmods-zfs/

# Install
dnf5 --repo=fedora,updates -y install /tmp/akmods-zfs/kmods/zfs/*.rpm

# Depmod and autoload
depmod -a "${KERNEL}"
echo "zfs" >/usr/lib/modules-load.d/zfs.conf

echo "::endgroup::"
