#!/usr/bin/bash

set -ouex pipefail

# Nvidia Configurations
if [[ ${IMAGE_FLAVOR} =~ "nvidia" || ${NVIDIA_TYPE} =~ "nvidia" ]]; then
	# Disable GSP on -nvidia builds
	cat <<EOF >/usr/lib/modprobe.d/nvidia-gsp-workaround.conf
options nvidia NVreg_EnableGpuScreenPreemption=0
EOF

	# Firefox Nvidia config
	cat <<EOF >/usr/lib64/firefox/defaults/pref/00-sarkinite-nvidia.js
pref("widget.dmabuf.force-enabled", true);
EOF

	# Nvidia Just commands
	cat <<EOF >/tmp/just/95-nvidia.just
enable-supergfxctl:
    systemctl enable --now supergfxd.service
EOF

	# Use OpenGL renderer for GSK
	cat <<EOF >/etc/environment.d/99-gsk-renderer-opengl.conf
GSK_RENDERER=ngl
EOF

fi
