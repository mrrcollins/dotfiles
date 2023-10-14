#!/bin/bash

apps="vim git tmux mosh socat curl rsync"

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
    echo "Clone alfredprefs"
    if [ ! -d ~/.config/alfredprefs ]; then
       git clone --quiet git@github.com:mrrcollins/alfredprefs.git ~/.config/alfredprefs
    else
       echo "~/.config/alfredprefs already exists..."
    fi
    echo "Clone iterm2prefs"
    if [ ! -d ~/.config/iterm2prefs ]; then
       git clone --quiet git@github.com:mrrcollins/iterm2prefs.git ~/.config/iterm2prefs
    else
       echo "~/.config/iterm2prefs already exists..."
    fi
    cd ~/Downloads
    rsync -avp venkman:~/.config/macOS/ .
    cd
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

echo "Clone Espanso"
if [ ! -d ~/.config/espanso ]; then
   git clone --quiet git@github.com:mrrcollins/espanso.git ~/.config/espanso
else
   echo "~/.config/espanso already exists..."
fi


cd ~

