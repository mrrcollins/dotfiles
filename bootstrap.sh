#!/bin/bash

echo "Install the default apps..."
sudo apt update
sudo apt install vim git tmux mosh

echo "Set up dotfiles..."
. setupdotfiles.sh

echo "Set up Vim..."
cd ~/
git clone https://github.com/mrrcollins/vim.git .vim
cd .vim
. setupvim.sh
ln -s ~/.vim/.vimrc ~/.vimrc

