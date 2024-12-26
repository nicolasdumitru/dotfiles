#!/bin/bash

# Config for bash shells

# All bash shells:

# Environment variables
# Shared (these must be loaded first)
. "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/environmentrc

# Bash idiosyncrasy
export BASH_ENV="${XDG_CONFIG_HOME:-$HOME/.config}"/bash/bash-profile

# If not running interactively, don't do anything else
if [[ $- != *i* ]]; then
	return 0
fi

umask 077

# Interactive config
# History configuration
HISTFILE="$XDG_STATE_HOME"/bash/history

# Load aliases
. "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/aliasrc

# Load functions
. "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/functionrc

# This ensures that, should something go catastrophically wrong with nushell,
# a bash login shell can still be accessed from a tty for recovery purposes.
NU="$(command -v nu)"
if [[ -x "$NU" ]] && ! shopt -q login_shell; then
    # Use nushell in interactive non-login shells.
    SHELL="$NU" exec nu
else
    # vi keybindings
    set -o vi
    # ctrl-l clear
    bind -m vi-command 'Control-l: clear-screen'
    bind -m vi-insert 'Control-l: clear-screen'
fi
