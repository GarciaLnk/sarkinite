#!/usr/bin/fish

# ls aliases
if [ "$(command -v eza)" ]
    alias ll='eza -l --icons=auto --group-directories-first'
    alias l.='eza -d .*'
    alias ls='eza'
    alias l1='eza -1'
end

# ugrep for grep
if [ "$(command -v ug)" ]
    alias grep='ug'
    alias egrep='ug -E'
    alias fgrep='ug -F'
    alias xzgrep='ug -z'
    alias xzegrep='ug -zE'
    alias xzfgrep='ug -zF'
end

# bat for cat
if [ "$(command -v bat)" ]
    alias cat='bat -p'
end

if status is-interactive
    [ "$(command -v starship)" ] && starship init fish | source
    [ "$(command -v fzf)" ] && fzf --fish | source
    [ "$(command -v zoxide)" ] && eval "$(zoxide init fish)"
	[ "$(command -v direnv)" ] && eval "$(direnv hook fish)"
end

set HB_CNF_HANDLER (brew --repository)"/Library/Taps/homebrew/homebrew-command-not-found/handler.fish"
if test -f $HB_CNF_HANDLER
   source $HB_CNF_HANDLER
end
