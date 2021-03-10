#!/bin/bash

cwd=$(pwd)

cd ${HOME}/notes
#${HOME}/.config/dotfiles/scripts/git-sync
./notesync.sh

cd "${cwd}"
