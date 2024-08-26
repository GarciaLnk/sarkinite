#!/usr/bin/bash
#shellcheck disable=SC2154,SC2034

# shellcheck disable=SC1091
. "${project_root}/scripts/sudoif.sh"

# Check if inside rootless container
if [[ -f /run/.containerenv ]]; then
	#shellcheck disable=SC1091
	source /run/.containerenv
	#shellcheck disable=SC2154
	if [[ ${rootless} -eq "1" ]]; then
		echo "Cannot build ISO inside rootless podman container... Exiting..."
		exit 1
	fi
fi
container_mgr=$(just _container_mgr)
# If using rootless container manager, exit. Might not be best check
if "${container_mgr}" info | grep Root | grep -q /home; then
	echo "Cannot build ISO with rootless container..."
	exit 1
fi

# Get Inputs
image=$1
target=$2
version=$3

# Set image/target/version based on inputs
# shellcheck disable=SC2154,SC1091
. "${project_root}/scripts/get-defaults.sh"

# Set Container tag name
tag=$(just _tag "${image}" "${target}")

# Don't use -build suffix, flatpak dependency using ghcr
ghcr_tag=${tag::-6}

# Remove old ISO if present
sudoif rm -f "${project_root}/scripts/files/output/${tag}-${version}-${git_branch}.iso"
sudoif rm -f "${project_root}/scripts/files/output/${tag}-${version}-${git_branch}.iso-CHECKSUM"

# Set Base Image
base_image=$(just _base_image "${image}")

if [[ ${version} == "stable" ]]; then
	KERNEL_RELEASE=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '.Labels["ostree.linux"] | split(".x86_64")[0]')
elif [[ ${version} == "gts" ]]; then
	coreos_kernel_release=$(skopeo inspect docker://quay.io/fedora/fedora-coreos:stable | jq -r '.Labels["ostree.linux"] | split(".x86_64")[0]')
	major_minor_patch=$(echo "${coreos_kernel_release}" | cut -d '-' -f 1)
	coreos_fedora_version=$(echo "${coreos_kernel_release}" | grep -oP 'fc\K[0-9]+')
	KERNEL_RELEASE="${major_minor_patch}-200.fc$(("${coreos_fedora_version}" - 1))"
else
	KERNEL_RELEASE=$(skopeo inspect docker://ghcr.io/ublue-os/silverblue-main:"${version}" | jq -r '.Labels["ostree.linux"] | split(".x86_64")[0]')
fi
fedora_version=$(echo "${KERNEL_RELEASE}" | grep -oP 'fc\K[0-9]+')

# Set variant and flatpak dir
if [[ ${base_image} =~ "silverblue" ]]; then
	variant=Silverblue
	flatpak_dir_shortname="flatpaks_gnome"
elif [[ ${base_image} =~ "kinoite" ]]; then
	variant=Kinoite
	flatpak_dir_shortname="flatpaks_kde"
else
	exit 1
fi

# Make sure image actually exists, build if it doesn't
ID=$(${container_mgr} images --filter reference=localhost/"${tag}:${version}-${git_branch}" --format "{{.ID}}")
if [[ -z ${ID} ]]; then
	just build "${image}" "${target}" "${version}"
fi

# Make temp space
TEMP_FLATPAK_INSTALL_DIR=$(mktemp -d -p "${project_root}" flatpak.XXX)
# Get list of refs from directory
FLATPAK_REFS_DIR=${project_root}/${flatpak_dir_shortname}
FLATPAK_REFS_DIR_LIST=$(tr '\n' ' ' <"${FLATPAK_REFS_DIR}/flatpaks")

# Generate install script
cat <<EOF >"${TEMP_FLATPAK_INSTALL_DIR}/script.sh"
cat /temp_flatpak_install_dir/script.sh
mkdir -p /flatpak/flatpak /flatpak/triggers
mkdir /var/tmp || true
chmod -R 1777 /var/tmp
flatpak config --system --set languages "*"
flatpak remote-add --system flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install --system -y ${FLATPAK_REFS_DIR_LIST}
ostree refs --repo=\${FLATPAK_SYSTEM_DIR}/repo | grep '^deploy/' | grep -v 'org\.freedesktop\.Platform\.openh264' | sed 's/^deploy\///g' > /output/flatpaks_with_deps
EOF

workspace=${project_root}
if [[ -f /.dockerenv || -f /run/.containerenv ]]; then
	FLATPAK_REFS_DIR=${LOCAL_WORKSPACE_FOLDER}/${flatpak_dir_shortname}
	TEMP_FLATPAK_INSTALL_DIR="${LOCAL_WORKSPACE_FOLDER}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)"
	workspace=${LOCAL_WORKSPACE_FOLDER}
fi

if [[ ${version} == "stable" ]]; then
	main_version="latest"
else
	main_version="${version}"
fi

# Generate Flatpak Dependency List
if [[ ! -f ${project_root}/${flatpak_dir_shortname}/flatpaks_with_deps ]]; then
	"${container_mgr}" run --rm --privileged \
		--entrypoint bash \
		-e FLATPAK_SYSTEM_DIR=/flatpak/flatpak \
		-e FLATPAK_TRIGGERSDIR=/flatpak/triggers \
		--volume "${FLATPAK_REFS_DIR}":/output \
		--volume "${TEMP_FLATPAK_INSTALL_DIR}":/temp_flatpak_install_dir \
		"ghcr.io/ublue-os/${base_image}-main:${main_version}" /temp_flatpak_install_dir/script.sh
fi

# Remove Temp Directory
if [[ -f /.dockerenv ]]; then
	TEMP_FLATPAK_INSTALL_DIR=${project_root}/$(echo "${TEMP_FLATPAK_INSTALL_DIR}" | rev | cut -d / -f 1 | rev)
fi
rm -rf "${TEMP_FLATPAK_INSTALL_DIR}"
