#!/usr/bin/env bash

set -ou pipefail

# Source libujust for colors/ugum
source /usr/lib/ujust/ujust.sh

# Exit Handling
function Exiting() {
	printf "%s%sExiting...%s\n" "${red}" "${bold}" "${normal}"
	printf "Rerun script with %s%sujust sarkinite-cli%s\n" "${blue}" "${bold}" "${normal}"
	exit 0
}

# Trap function
function ctrl_c() {
	printf "\nSignal SIGINT caught\n"
	Exiting
}

# Brew Bundle Install
function brew-bundle() {
	echo 'Installing bling from Homebrew 🍻🍻🍻'
	brew bundle --file /usr/share/ublue-os/homebrew/sarkinite-cli.Brewfile
}

# Check if bling is already sourced
function check-bling() {
	shell="$1"
	if [[ ${shell} == "bash" ]]; then
		if [[ -f /etc/profile.d/bling.sh ]]; then
			return 1
		fi
		return 0
	else
		echo 'Unknown Shell ... You are on your own'
		exit 1
	fi
}

# Add Bling
function add-bling() {
	shell="$1"
	if ! brew-bundle; then
		Exiting
	fi
	echo 'Setting up your Shell 🐚🐚🐚'
	if [[ ${shell} == "bash" ]]; then
		echo 'Adding bling to /etc/profile.d/bling.sh 💥💥💥'
		sudo bash -c 'cat <<EOF >/etc/profile.d/bling.sh
			#!/usr/bin/bash
			### bling.sh source start
			test -f /usr/share/ublue-os/sarkinite-cli/bling.sh && source /usr/share/ublue-os/sarkinite-cli/bling.sh
			### bling.sh source end
			EOF'
		sudo chmod +x /etc/profile.d/bling.sh
	else
		echo 'Unknown Shell ... You are on your own'
	fi
}

# Remove bling, handle if old method
function remove-bling() {
	shell="$1"
	if [[ ${shell} == "bash" ]]; then
		if [[ -f /etc/profile.d/bling.sh ]]; then
			sudo rm -f /etc/profile.d/bling.sh
		fi
	fi
}

# Main function.
function main() {

	# Get Shell
	shell=$(basename "${SHELL}")
	reentry="$1"
	clear
	if [[ -n ${reentry-} ]]; then
		printf "%s%s%s\n\n" "${bold}" "${reentry}" "${normal}"
	fi

	# Check if bling is enabled and display
	printf "Shell:\t%s%s%s%s\n" "${green}" "${bold}" "${shell}" "${normal}"
	if ! check-bling "${shell}"; then
		printf "Bling:\t%s%sEnabled%s\n" "${green}" "${bold}" "${normal}"
	else
		printf "Bling:\t%s%sDisabled%s\n" "${red}" "${bold}" "${normal}"
	fi

	# ugum enable/disable
	CHOICE=$(Choose enable disable cancel)

	# Enable/Disable. Recurse if bad option.
	if [[ ${CHOICE} == "enable" ]]; then
		if check-bling "${shell}"; then
			trap ctrl_c SIGINT
			add-bling "${shell}"
			# set preset for starship
			STARSHIP_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/starship.toml"
			if [[ -n "$(command -v starship)" ]]; then
				starship preset nerd-font-symbols -o "${STARSHIP_CONFIG}"
			fi
			printf "%s%sInstallation Complete%s ... please close and reopen your terminal!" "${green}" "${bold}" "${normal}"
		else
			main "Bling is already configured ..."
		fi
	elif [[ ${CHOICE} == "disable" ]]; then
		if check-bling "${shell}"; then
			main "Bling is not yet configured ..."
		else
			remove-bling "${shell}"
			trap ctrl_c SIGINT
			printf "%s%sBling Removed%s ... please close and reopen your terminal\n" "${red}" "${bold}" "${normal}"
		fi
	else
		Exiting
	fi
}

# Entrypoint
main ""
