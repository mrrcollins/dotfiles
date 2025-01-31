#!/bin/bash

dotfiles=(tmux.conf bash_aliases bash_profile bashrc gitconfig)
cwd=$(pwd)

if [ -d ${HOME}/.config/dotfiles ]; then
    cd ${HOME}/.config/dotfiles
else
    echo "No dotfiles directory"
    exit
fi


for i in "${dotfiles[@]}"; 
do 

    DFILE="${HOME}/.${i}"
    echo "Working on $i (destination ${DFILE})..."

    if [ ! -L "${DFILE}" ]; then
        echo "Symlink ${DFILE} doesn't exist"
        if [ -f "${DFILE}" ]; then 
            BACKUP=${DFILE}.$(date +"%Y%m%d%H%M%S")
            echo "${DFILE} file exists, backing it up to ${BACKUP}"
            mv ${DFILE} ${BACKUP}
        fi
        
        echo "Creating symlink for ${i}"
        ln -s "${cwd}/${i}" "${DFILE}"
    else
        echo "Skipping ${DFILE}, symlink already exists."
    fi

done

