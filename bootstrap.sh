#!/bin/bash

sudo -v > /dev/null
SUDOACCESS=$?

if [ ${SUDOACCESS} -eq 0 ]; then
echo "Install the default apps..."
    [ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -1)" ] && sudo apt -qq update
    sudo apt -qq install vim git tmux mosh
else
    echo "No sudo access, skipping install."
fi

echo "Set up dotfiles..."
. setupdotfiles.sh

echo "Set up Vim..."
if [ ! -d ~/.vim ]; then
    git clone --quiet git@github.com:mrrcollins/vim.git ~/.vim
    cd ~/.vim
    . bootstrap.sh
else
    echo "~/.vim already exists..."
fi

cd ~

