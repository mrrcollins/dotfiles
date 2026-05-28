#!/bin/bash

cwd=$(pwd)

cd ${HOME}/notes
#${HOME}/.config/dotfiles/scripts/git-sync
bash ./notesync.sh

cd "${cwd}"
