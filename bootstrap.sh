#!/bin/bash

echo "Install the default apps..."
sudo apt update
sudo apt install vim git tmux mosh

echo "Set up dotfiles..."
. setupdotfiles.sh

echo "Set up Vim..."
git clone https://github.com/mrrcollins/vim.git ~/.vim
cd ~/.vim
. bootstrap.sh

