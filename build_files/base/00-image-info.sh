#!/usr/bin/env bash

set -ouex pipefail

IMAGE_PRETTY_NAME="Sarkinite"
IMAGE_LIKE="fedora"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"

# Image Flavor
image_flavor="main"
if [[ ${IMAGE_NAME} =~ nvidia ]]; then
	image_flavor="nvidia"
fi

cat >"${IMAGE_INFO}" <<EOF
{
  "image-name": "${IMAGE_NAME}",
  "image-flavor": "${image_flavor}",
  "image-vendor": "${IMAGE_VENDOR}",
  "image-ref": "${IMAGE_REF}",
  "image-tag":"${UBLUE_IMAGE_TAG}",
  "base-image-name": "${BASE_IMAGE_NAME}",
  "fedora-version": "${FEDORA_MAJOR_VERSION}"
}
EOF

# OS Release File
sed -i "s/^VARIANT_ID=.*/VARIANT_ID=${IMAGE_NAME}/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} ${FEDORA_MAJOR_VERSION}\"/" /usr/lib/os-release
sed -i "s/^NAME=.*/NAME=\"${IMAGE_PRETTY_NAME}\"/" /usr/lib/os-release
sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:universal-blue:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${IMAGE_PRETTY_NAME,}\nID_LIKE=\"${IMAGE_LIKE}\"/" /usr/lib/os-release
sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release

if [[ -n ${SHA_HEAD_SHORT-} ]]; then
	echo "BUILD_ID=\"${SHA_HEAD_SHORT}\"" >>/usr/lib/os-release
fi

# Fix issues caused by ID no longer being fedora
sed -i 's/^EFIDIR=.*/EFIDIR="fedora"/' /usr/sbin/grub2-switch-to-blscfg
