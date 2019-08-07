#!/bin/bash

echo "Updating system software..."
sudo -v > /dev/null
SUDOACCESS=$?

if [ ${SUDOACCESS} -eq 0 ]; then
    [ -z "$(find -H /var/lib/apt/lists -maxdepth 0 -mtime -1)" ] && sudo apt -qq update
    sudo apt -qq upgrade
else
    echo "No sudo access, skipping update."
fi

# Update dotfiles repo
echo "Checking/updating dotfiles..."    
git pull --quiet

#update .vim
echo "Checking/update .vim..."
git -C ~/.vim pull --quiet

#update vim plugins
for i in ~/.vim/bundle/*; do 
    echo "Checking/updating ${i}..."    
    git -C $i pull --quiet
done

