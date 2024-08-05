#!/bin/bash

read -p "Install espanso? " i
if [ "${i}" == "y" ]; then
    if [ ! -d ~/.config/espanso ]; then
        git clone --quiet git@github.com:mrrcollins/espanso.git ~/.config/espanso
    else
        echo "~/.config/espanso already exists..."
    fi
    
    cd "/tmp"
    wget https://github.com/federico-terzi/espanso/releases/latest/download/espanso-debian-${XDG_SESSION_TYPE}-amd64.deb
    sudo apt install ./espanso-debian-${XDG_SESSION_TYPE}-amd64.deb
    espanso service register
    espanso start
fi

