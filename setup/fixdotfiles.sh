#!/bin/bash

dotfiles=(tmux.conf bash_aliases bash_profile bashrc gitconfig)
cwd=$(pwd)

if [ -d ${HOME}/.config/dotfiles/setup ]; then
    cd ${HOME}/.config/dotfiles/setup
else
    echo "No dotfiles directory"
    exit
fi


for i in "${dotfiles[@]}"; 
do 

    DFILE="${HOME}/.${i}"
    echo "Working on $i (destination ${DFILE})..."

    if [ ! -e "${DFILE}" ]; then
        echo "Symlink ${DFILE} is broken, fixing..."
        rm "${DFILE}"
        ln -s "${cwd}/${i}" "${DFILE}"
    else
        echo "Skipping ${DFILE}, symlink already exists."
    fi

done

