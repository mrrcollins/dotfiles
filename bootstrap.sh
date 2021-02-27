#!/bin/bash

apps="vim git tmux mosh socat"

ostype=$(uname -a)
uname -a | grep -q Android
android=$?

if [[ "$ostype" =~ "Alpine" ]]; then
    sudo apk update
    sudo apk upgrade
	sudo apk add $apps
elif [[ "$ostype" =~ "Android" ]]; then
    apt update
    apt upgrade
	apt install $apps
elif [[ "$ostype" =~ "Darwin" ]]; then
    brew update
    brew upgrade
	brew install $apps
elif [ ! $android ]; then
    apt update
	apt install $apps
    apt upgrade
else
    sudo apt update
    sudo apt upgrade
	sudo apt install $apps
fi

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

