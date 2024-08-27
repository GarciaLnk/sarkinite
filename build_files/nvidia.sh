#!/usr/bin/bash

set -ouex pipefail

# Nvidia Configurations
if [[ ${IMAGE_FLAVOR} =~ "nvidia" || ${NVIDIA_TYPE} =~ "nvidia" ]]; then
	# Restore x11 for Nvidia Images
	if [[ ${BASE_IMAGE_NAME} =~ "kinoite" && ${FEDORA_MAJOR_VERSION} -gt "39" ]]; then
		rpm-ostree install plasma-workspace-x11
	fi

	# Disable GSP on -nvidia builds
	cat <<EOF >/usr/lib/modprobe.d/nvidia-gsp-workaround.conf
options nvidia NVreg_EnableGpuScreenPreemption=0
EOF

	# Firefox Nvidia config
	cat <<EOF >/usr/lib64/firefox/defaults/pref/00-sarkinite-nvidia.js
pref("widget.dmabuf.force-enabled", true);
EOF

fi
