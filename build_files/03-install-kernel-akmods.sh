#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail

# Remove Existing Kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
	rpm --erase "${pkg}" --nodeps
done

# Fetch Kernel
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/"${AKMODS_FLAVOR}"-kernel:"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/kernel-rpms
KERNEL_TARGZ=$(jq -r '.layers[].digest' </tmp/kernel-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/kernel-rpms/"${KERNEL_TARGZ}" -C /
mv /tmp/rpms/* /tmp/kernel-rpms/

# Install Kernel
rpm-ostree install \
	/tmp/kernel-rpms/kernel-[0-9]*.rpm \
	/tmp/kernel-rpms/kernel-core-*.rpm \
	/tmp/kernel-rpms/kernel-modules-*.rpm

# Fetch Kernel RPMS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/"${AKMODS_FLAVOR}"-kernel:"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/kernel-rpms
KERNEL_TARGZ=$(jq -r '.layers[].digest' </tmp/kernel-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/kernel-rpms/"${KERNEL_TARGZ}" -C /
mv /tmp/rpms/* /tmp/kernel-rpms/

# Fetch Common AKMODS
skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"${AKMODS_TARGZ}" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/

# Everyone
sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

if ! rpm -qa | grep kernel-devel; then
	rpm-ostree install /tmp/kernel-rpms/kernel-devel-*.rpm
fi

rpm-ostree install \
	/tmp/akmods/kmods/*xone*.rpm \
	xpadneo /tmp/akmods/kmods/*xpadneo*.rpm \
	/tmp/akmods/kmods/*openrazer*.rpm \
	/tmp/akmods/kmods/*framework-laptop*.rpm \
	/tmp/akmods/kmods/*kvmfr*.rpm

# RPMFUSION Dependent AKMODS
rpm-ostree install \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-"${FEDORA_MAJOR_VERSION}".noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-"${FEDORA_MAJOR_VERSION}".noarch.rpm
rpm-ostree install \
	v4l2loopback /tmp/akmods/kmods/*v4l2loopback*.rpm
rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
# disable any remaining rpmfusion repos
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion*.repo

# Nvidia AKMODS
if [[ ${IMAGE_NAME} =~ nvidia ]]; then
	# Fetch Nvidia RPMs
	skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods-nvidia-open:"${AKMODS_FLAVOR}"-"${FEDORA_MAJOR_VERSION}"-"${KERNEL}" dir:/tmp/akmods-rpms
	NVIDIA_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods-rpms/manifest.json | cut -d : -f 2)
	tar -xvzf /tmp/akmods-rpms/"${NVIDIA_TARGZ}" -C /tmp/
	mv /tmp/rpms/* /tmp/akmods-rpms/

	# Install Nvidia RPMs
	/ctx/build_files/99-nvidia.sh
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
rpm-ostree install "${ZFS_RPMS[@]}"

# Depmod and autoload
depmod -a -v "${KERNEL}"
echo "zfs" >/usr/lib/modules-load.d/zfs.conf

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo

echo "::endgroup::"
