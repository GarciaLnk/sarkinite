#!/usr/bin/bash
function sudoif() {
	if [[ ${TERM_PROGRAM-} == "vscode" &&
		! -f /run/.containerenv &&
		! -f /.dockerenv ]]; then
		[[ -n $(command -v systemd-run) ]] &&
			/usr/bin/systemd-run --uid=0 --gid=0 -d -E TERM="${TERM}" -t -q -P -G "$@" ||
			exit 1
	elif [[ -n $(command -v sudo) && -n ${SSH_ASKPASS-} && -n ${DISPLAY-} ]]; then
		/usr/bin/sudo --askpass "$@" || exit 1
	elif [[ -n $(command -v sudo) ]]; then
		/usr/bin/sudo "$@" || exit 1
	else
		exit 1
	fi
}
