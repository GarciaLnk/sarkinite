#!/usr/bin/env sh

# shellcheck disable=SC1091,SC1090

# Check if bling has already been sourced
[ "${BLING_SOURCED:-0}" -eq 1 ] && return
BLING_SOURCED=1

# ls aliases
if [ -n "$(command -v eza)" ]; then
	alias ll='eza -l --icons=auto --group-directories-first'
	alias la='eza -lA --icons=auto --group-directories-first'
	alias l.='eza -d .*'
	alias ls='eza'
	alias l1='eza -1'
fi

# ugrep for grep
if [ -n "$(command -v ug)" ]; then
	alias grep='ug'
	alias egrep='ug -E'
	alias fgrep='ug -F'
	alias xzgrep='ug -z'
	alias xzegrep='ug -zE'
	alias xzfgrep='ug -zF'
fi

# bat for cat
if [ -n "$(command -v bat)" ]; then
	alias cat='bat -pp'
fi

# set micro as default editor
if [ -n "$(command -v micro)" ]; then
	export EDITOR='micro'
fi

if [ "$(basename "${SHELL}")" = "bash" ]; then
	[ -f "${HOMEBREW_PREFIX}"/etc/profile.d/bash-preexec.sh ] && . "${HOMEBREW_PREFIX}"/etc/profile.d/bash-preexec.sh
	[ -n "$(command -v starship)" ] && eval "$(starship init bash)"
	[ -n "$(command -v fzf)" ] && eval "$(fzf --bash)"
	[ -n "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
	[ -n "$(command -v direnv)" ] && eval "$(direnv hook bash)"
elif [ "$(basename "${SHELL}")" = "zsh" ]; then
	[ -n "$(command -v starship)" ] && eval "$(starship init bash)"
	[ -n "$(command -v fzf)" ] && fzf --zsh >/tmp/fzf.zsh && . /tmp/fzf.zsh && rm /tmp/fzf.zsh
	[ -n "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
	[ -n "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
fi

HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
if [ -f "${HB_CNF_HANDLER}" ]; then
	. "${HB_CNF_HANDLER}"
fi
