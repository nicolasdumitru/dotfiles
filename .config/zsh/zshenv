#!/bin/zsh

# Environment variables are set here.

# Shared (these must be loaded first)
if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/environmentrc ]; then
	. "${XDG_CONFIG_HOME:-$HOME/.config}"/shell/environmentrc
else
	command echo "environmentrc could not be found"
fi

# Make sure $SHELL is zsh
export __SHELL="$(command -v zsh)"
export SHELL="${__SHELL}" # Do not modify this; modify __SHELL

# Zsh-specific
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}"/zsh
