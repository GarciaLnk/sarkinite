#!/usr/bin/env bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

VERSION="${VERSION:-00.00000000}"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"

# Image Flavor
IMAGE_FLAVOR="main"
if [[ ${IMAGE_NAME} =~ nvidia ]]; then
	IMAGE_FLAVOR="nvidia"
fi

cat >/usr/share/ublue-os/image-info.json <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-flavor": "${IMAGE_FLAVOR}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "${IMAGE_REF}",
  "image-tag":"${IMAGE_TAG}",
  "fedora-version": "${FEDORA_MAJOR_VERSION}"
}
EOF

# OS Release File
sed -i "s|^NAME=.*|NAME=Sarkinite|" /usr/lib/os-release
sed -i "s|^VERSION=.*|VERSION=\"${VERSION} (Kinoite)\"|" /usr/lib/os-release
sed -i "s|^ID=fedora|ID=sarkinite\nID_LIKE=fedora|" /usr/lib/os-release
sed -i "s|^VARIANT_ID=.*|VARIANT_ID=${IMAGE_NAME}|" /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=\"Sarkinite (Version: ${VERSION})\"|" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:garcialnk:sarkinite:${VERSION}|" /usr/lib/os-release
sed -i "s|^DEFAULT_HOSTNAME=.*|DEFAULT_HOSTNAME=sarkinite|" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
sed -i "s|^OSTREE_VERSION=.*|OSTREE_VERSION=\"${VERSION}\"|" /usr/lib/os-release

if [[ -n ${SHA_HEAD_SHORT-} ]]; then
	echo "BUILD_ID=\"${SHA_HEAD_SHORT}\"" >>/usr/lib/os-release
fi

# Added in systemd 249.
# https://www.freedesktop.org/software/systemd/man/latest/os-release.html#IMAGE_ID=
echo "IMAGE_ID=${IMAGE_NAME}" >>/usr/lib/os-release
echo "IMAGE_VERSION=${VERSION}" >>/usr/lib/os-release

# Fix issues caused by ID no longer being fedora
sed -i 's|^EFIDIR=.*|EFIDIR="fedora"|' /usr/sbin/grub2-switch-to-blscfg

echo "::endgroup::"
