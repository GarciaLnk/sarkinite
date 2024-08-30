#!/bin/bash

export MOZ_ENABLE_WAYLAND=1
export MOZ_USE_XINPUT2=1

if [[ ${IMAGE_FLAVOR} =~ "nvidia" ]] && [[ "$(grep -o "\-display" <<<"$(lshw -C display)")" -le 1 ]] && grep -q "vendor: NVIDIA Corporation" <<<"$(lshw -C display)"; then
	export LIBVA_DRIVER_NAME=nvidia
	export LIBVA_DRIVERS_PATH=/run/host/usr/lib64/dri
	export LIBVA_MESSAGING_LEVEL=1
	export MOZ_DISABLE_RDD_SANDBOX=1
	export NVD_BACKEND=direct
fi
