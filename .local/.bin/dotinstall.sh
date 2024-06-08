#!/bin/sh
set -e

WORKTREE="${HOME}"
TARGET="${WORKTREE}/.dotfiles"
REPO="nicolasdumitru/dotfiles"

config () {
    command git --git-dir="${TARGET}" --work-tree="${WORKTREE}" "$@"
}

readoption () {
	option=''
	read_ok=0

    echo "Type 'y' for 'yes' or 'n' for 'no' (default NO):"
	while [ $read_ok -eq 0 ]; do
		read -r option

		case "$option" in
			y) read_ok=1 ;;
			n) exit 1 ;;
			*) echo "wrong option" ;;
		esac
	done
}

git clone --bare "https://github.com/${REPO}.git" "${TARGET}"

config checkout || {
    echo "The files listed above will be overwritten."
    echo "If you would like to avoid that, back them up before proceeding."
    echo "Proceed anyway?"
    readoption
    config checkout --force
}

config config --local status.showUntrackedFiles no
config remote set-url --push origin git@github.com:nicolasdumitru/dotfiles.git

echo
echo "The configuration files were installed successfully."
echo "Status:"
config status
