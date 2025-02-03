#!/usr/bin/env bash

if [[ ${XDG_SESSION_TYPE} != "tty" ]]; then # if this is a gui session (not tty)
	# let's use fcitx instead of fcitx5 to make flatpak happy
	# this may break behavior for users who have installed both
	# fcitx and fcitx5, let then change the file on their own
	export INPUT_METHOD=fcitx
	export XMODIFIERS=@im=fcitx
fi
