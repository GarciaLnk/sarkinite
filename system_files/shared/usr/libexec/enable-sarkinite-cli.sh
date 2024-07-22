#!/usr/bin/bash

# Choose to enable or disable sarkinite-cli

# shellcheck disable=1091
# shellcheck disable=2206
# shellcheck disable=2154
source /usr/lib/ujust/ujust.sh

sarkinite_cli=(${red}Disabled${n} ${red}Inactive${n} ${red}Not Default${n})

function get_status() {
	if systemctl --quiet --user is-enabled sarkinite-cli.target; then
		sarkinite_cli[0]="${green}Enabled${n}"
	else
		sarkinite_cli[0]="${red}Disabled${n}"
	fi
	if systemctl --quiet --user is-active sarkinite-cli.service; then
		sarkinite_cli[1]="${green}Active${n}"
	else
		sarkinite_cli[1]="${red}Inactive${n}"
	fi
	echo "Sarkinite-cli is currently ${b}${sarkinite_cli[0]}${n} (run status), and ${b}${sarkinite_cli[1]}${n} (on boot status)."
}

function logic() {
	if test "${toggle}" = "Enable"; then
		echo "${b}${green}Enabling${n} Sarkinite-CLI"
		systemctl --user enable --now sarkinite-cli.target >/dev/null 2>&1
		if ! systemctl --quiet --user is-active sarkinite-cli.service; then
			systemctl --user reset-failed sarkinite-cli.service >/dev/null 2>&1 || true
			echo "${b}${green}Starting${n} Sarkinite-CLI"
			systemctl --user start sarkinite-cli.service
		fi
	elif test "${toggle}" = "Disable"; then
		echo "${b}${red}Disabling${n} Sarkinite-CLI"
		systemctl --user disable --now sarkinite-cli.target >/dev/null 2>&1
		if systemctl --quiet --user is-active sarkinite-cli.service; then
			echo "Do you want to ${b}${red}Stop${n} the Container?"
			stop=$(Confirm)
			if test "${stop}" -eq 0; then
				systemctl --user stop sarkinite-cli.service >/dev/null 2>&1
				systemctl --user reset-failed sarkinite-cli.service >/dev/null 2>&1 || true
			fi
		fi
	else
		echo "Not Changing"
	fi
}

function main() {
	get_status
	toggle=$(Choose Enable Disable Cancel)
	logic
	get_status
}

main
