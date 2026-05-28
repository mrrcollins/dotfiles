#!/bin/bash

read -p "Install espanso? " i
if [ "${i}" == "y" ]; then
    if [ ! -d ~/.config/espanso ]; then
        git clone --quiet git@github.com:mrrcollins/espanso.git ~/.config/espanso
    else
        echo "~/.config/espanso already exists..."
    fi
    
    cd "/tmp"

    ##wget https://github.com/federico-terzi/espanso/releases/latest/download/espanso-debian-${XDG_SESSION_TYPE}-amd64.deb
    ##sudo apt install ./espanso-debian-${XDG_SESSION_TYPE}-amd64.deb

    # Create the $HOME/opt destination folder
    mkdir -p ~/opt
    # Download the AppImage inside it
    wget -O ~/opt/Espanso.AppImage 'https://github.com/espanso/espanso/releases/download/v2.2.1/Espanso-X11.AppImage'
    # Make it executable
    chmod u+x ~/opt/Espanso.AppImage
    # Create the "espanso" command alias
    sudo ~/opt/Espanso.AppImage env-path register
    espanso service register
    espanso start
fi

