#!/bin/bash

export MOZ_ENABLE_WAYLAND=1

if [[ $(cat /etc/ublue/image_flavor) =~ "nvidia" ]] && [[ "$(grep -o "\-display" <<<"$(lshw -C display)")" -le 1 ]] && grep -q "vendor: NVIDIA Corporation" <<<"$(lshw -C display)"; then
	export MOZ_DISABLE_RDD_SANDBOX=1
fi
