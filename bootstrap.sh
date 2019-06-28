#!/bin/bash

echo "Install the default apps..."
sudo apt -qq update
sudo apt -qq install vim git tmux mosh

echo "Set up dotfiles..."
. setupdotfiles.sh

echo "Set up Vim..."
if [ ! -d ~/.vim ]; then
    git clone --quiet https://github.com/mrrcollins/vim.git ~/.vim
    cd ~/.vim
    . bootstrap.sh
else
    echo "~/.vim already exists..."
fi

cd ~

