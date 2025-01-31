#!/bin/bash


if [ ! -f /usr/local/espanso/bin/espanso ]; then
    cd ~/Downloads

    # Get it
    curl -sOL https://github.com/federico-terzi/espanso/releases/latest/download/espanso-mac.tar.gz

    # Decompress it
    tar zxvf espanso-mac.tar.gz

    # Put it in place
    sudo mkdir -p /usr/local/espanso/bin
    sudo cp espanso /usr/local/espanso/bin/espanso

    # Link it
    sudo ln -s /usr/local/espanso/bin/espanso /usr/local/bin

    # Get modulo
    curl -sOL https://github.com/federico-terzi/modulo/releases/latest/download/modulo-mac
    sudo cp modulo-mac /usr/local/bin/modulo

    # Check it
    espanso --version
    echo "Press a key to continue...";read -n 1 -s

    # Get expansions
    cd ~/.config/

    [[ -d espanso ]] || git clone https://github.com/mrrcollins/espanso.git

    cd espanso
    git pull

    # Register
    espanso register
    echo "Press a key to continue...";read -n 1 -s

    espanso start
fi

