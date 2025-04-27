#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Remove Existing Kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
	rpm --erase "${pkg}" --nodeps
done

# Fetch Common AKMODS & Kernel RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"${AKMODS_TARGZ}" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/
# NOTE: kernel-rpms should auto-extract into correct location

# Install Kernel
dnf5 --repo=fedora,updates -y install \
	/tmp/kernel-rpms/kernel-[0-9]*.rpm \
	/tmp/kernel-rpms/kernel-core-*.rpm \
	/tmp/kernel-rpms/kernel-modules-*.rpm

# TODO: Figure out why akmods cache is pulling in akmods/kernel-devel
dnf5 --repo=fedora,updates -y install \
	/tmp/kernel-rpms/kernel-devel-*.rpm

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

# Everyone
dnf5 --repofrompath=ublue-os-akmods,https://download.copr.fedorainfracloud.org/results/ublue-os/akmods/fedora-"${FEDORA_MAJOR_VERSION}"-x86_64/ \
	--repofrompath=terra,https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}" \
	--setopt=terra.gpgkey=https://repos.fyralabs.com/terra"${FEDORA_MAJOR_VERSION}"/key.asc \
	--setopt=ublue-os-akmods.gpgkey=https://download.copr.fedorainfracloud.org/results/ublue-os/akmods/pubkey.gpg \
	--repo=fedora,updates,ublue-os-akmods,terra -y install \
	v4l2loopback v4l2-relayd libcamera-v4l2 /tmp/akmods/kmods/*v4l2loopback*.rpm \
	xone-firmware /tmp/akmods/kmods/*xone*.rpm \
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

# Declare ZFS RPMs
ZFS_RPMS=(
	/tmp/akmods-zfs/kmods/zfs/kmod-zfs-"${KERNEL}"-*.rpm
	/tmp/akmods-zfs/kmods/zfs/libnvpair3-*.rpm
	/tmp/akmods-zfs/kmods/zfs/libuutil3-*.rpm
	/tmp/akmods-zfs/kmods/zfs/libzfs5-*.rpm
	/tmp/akmods-zfs/kmods/zfs/libzpool5-*.rpm
	/tmp/akmods-zfs/kmods/zfs/python3-pyzfs-*.rpm
	/tmp/akmods-zfs/kmods/zfs/zfs-*.rpm
	pv
)

# Install
dnf5 --repo=fedora,updates -y install "${ZFS_RPMS[@]}"

# Depmod and autoload
depmod -a "${KERNEL}"
echo "zfs" >/usr/lib/modules-load.d/zfs.conf

echo "::endgroup::"
