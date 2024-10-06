#!/usr/bin/env sh

# shellcheck disable=SC1091

# ls aliases
if [ -n "$(command -v eza)" ]; then
	alias ll='eza -l --icons=auto --group-directories-first'
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

if [ "$(basename "${SHELL}")" = "bash" ]; then
	[ -f "${HOMEBREW_PREFIX}"/etc/profile.d/bash-preexec.sh ] && . "${HOMEBREW_PREFIX}"/etc/profile.d/bash-preexec.sh
	[ -n "$(command -v fzf)" ] && eval "$(fzf --bash)"
	[ -n "$(command -v zoxide)" ] && eval "$(zoxide init bash)"
	[ -n "$(command -v direnv)" ] && eval "$(direnv hook bash)"
elif [ "$(basename "${SHELL}")" = "zsh" ]; then
	[ -n "$(command -v fzf)" ] && fzf --zsh >/tmp/fzf.zsh && . /tmp/fzf.zsh && rm /tmp/fzf.zsh
	[ -n "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"
	[ -n "$(command -v direnv)" ] && eval "$(direnv hook zsh)"
fi
