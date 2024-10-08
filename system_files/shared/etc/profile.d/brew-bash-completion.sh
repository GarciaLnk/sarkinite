#!/usr/bin/bash
# shellcheck disable=SC1090,SC1091,SC2039,SC2166
# Check for interactive bash and that we haven't already been sourced.
if [[ "x${BASH_VERSION-}" != x && "x${PS1-}" != x && ${BREW_BASH_COMPLETION-} == "" ]]; then

	# Check for recent enough version of bash.
	if [[ ${BASH_VERSINFO[0]} -gt 4 ]] ||
		[[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -ge 2 ]]; then
		if [[ -w /home/linuxbrew/.linuxbrew ]]; then
			if ! test -L /home/linuxbrew/.linuxbrew/etc/bash_completion.d/brew; then
				/home/linuxbrew/.linuxbrew/bin/brew completions link >/dev/null
			fi
		fi
		if test -d /home/linuxbrew/.linuxbrew/etc/bash_completion.d; then
			for rc in /home/linuxbrew/.linuxbrew/etc/bash_completion.d/*; do
				if test -r "${rc}"; then
					. "${rc}"
				fi
			done
			unset rc
		fi
	fi
	BREW_BASH_COMPLETION=1
	export BREW_BASH_COMPLETION
fi
