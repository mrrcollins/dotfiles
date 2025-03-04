#!/bin/bash


if [ ! -f /usr/local/espanso/bin/espanso ]; then
    cd ~/Downloads

    # Get it
    machine=$(uname -a)
    if [[ $machine =~ "ARM64" ]]; then
        app="Espanso-Mac-M1.zip"
    else
        app="Espanso-Mac-Intel.zip"
    fi
    
    curl -sOL https://github.com/federico-terzi/espanso/releases/latest/download/${app}

    # Decompress it
    unzip ${app}

    # Put it in place
    #sudo mkdir -p /usr/local/espanso/bin
    #sudo cp espanso /usr/local/espanso/bin/espanso
    mv Espanso.app ${HOME}/Applications
    open -a ${HOME}/Applications/Espanso.app

    # Link it
    #sudo ln -s /usr/local/espanso/bin/espanso /usr/local/bin/espanso

    # Get modulo
    #curl -sOL https://github.com/federico-terzi/modulo/releases/latest/download/modulo-mac
    #sudo cp modulo-mac /usr/local/bin/modulo

    # Check it
    #espanso --version
    #echo "Press a key to continue...";read -n 1 -s

    # Get expansions
    cd ~/.config/

    [[ -d espanso ]] || git clone git@github.com:mrrcollins/espanso.git

    cd espanso
    git pull

    # Register
    #espanso register
    #echo "Press a key to continue...";read -n 1 -s

    #espanso start
fi

