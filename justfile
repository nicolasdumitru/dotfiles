# List recipes
default:
    @just --list

source := justfile_directory()

restow:
    #!/bin/sh
    set -e
    cd {{source}}
    stow --dotfiles --target="$HOME" --restow .

unstow:
    #!/bin/sh
    set -e
    cd {{source}}
    stow --dotfiles --target="$HOME" --delete .
