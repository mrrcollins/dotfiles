#/bin/bash

mkdir -p "${HOME}/opt"

echo "Getting Obsidian AppImage..."
curl -L "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.6.7/Obsidian-1.6.7.AppImage" -o "${HOME}/opt/Obsidian.AppImage"
chmod a+x "${HOME}/opt/Obsidian.AppImage"

if [ ! -d "${HOME}/notes" ]; then
    read -p "Clone notes? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        cd ${HOME}
        git clone git@github.com:mrrcollins/notes.git
    else
        exit
    fi
fi


echo "Adding menu item..."
cp "${HOME}/notes/startobsidian.sh" "${HOME}/.local/bin/"
cp "${HOME}/notes/obsidian.desktop" "${HOME}/.local/share/applications"

