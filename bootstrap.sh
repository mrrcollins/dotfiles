#!/bin/bash


ostype=$(uname -a)
uname -a | grep -q Android
android=$?

if [[ "$ostype" =~ "Ubuntu" ]]; then
	apps="vim-nox git tmux mosh socat curl rsync unzip dialog htop autossh"
else
	apps="vim git tmux mosh socat curl rsync unzip dialog htop autossh"
fi

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
    echo "Install Fantasque Sans Mono"
    brew tap homebrew/cask-fonts #You only need to do this once for cask-fonts
    brew install --cask font-fantasque-sans-mono

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
    # Specify the preferences directory
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.dotfiles/System/iTerm/settings"
    #
    # Tell iTerm2 to use the custom preferences in the directory
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    echo "Get some files..."
    cd ~/Downloads
    rsync -avp venkman:~/.config/macOS/ .
    cd
elif [ ! $android ]; then
    apt update
	apt install $apps
    apt upgrade
else
    echo "Updating and installing ${apps}"
    sudo apt update
    sudo apt upgrade
	sudo apt install $apps -y

    read -p "Install fastfetch? " i
    if [ "$i" == "y" ]; then
        echo "Installing fastfetch..."
        mkdir -p "${HOME}/Downloads"
        cd "${HOME}/Downloads"
        curl -OL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
        sudo apt install ./fastfetch-linux-amd64.deb
        cd -
    fi

    read -p "Install fonts? " i
    if [ "$i" == "y" ]; then
        echo "Installing fonts..."
        cd /tmp
        mkdir -p FantasqueSansMono-Normal
        curl --silent -OL https://dtinth.github.io/comic-mono-font/ComicMono.ttf
        curl --silent -OL https://github.com/belluzj/fantasque-sans/releases/latest/download/FantasqueSansMono-Normal.tar.gz
        tar zxvf FantasqueSansMono-Normal.tar.gz -C FantasqueSansMono-Normal
        sudo cp ComicMono.ttf FantasqueSansMono-Normal/TTF/*.ttf /usr/share/fonts/
        fc-cache -f -v
        cd -
    fi
fi

# git stuff
if [ -f ${HOME}/.ssh/gitea.key ]; then
	git_key=$(cat ${HOME}/.ssh/gitea.key)
else
	read -p "What is your Git API key?" git_key
fi

## Set merge globally
git config --global pull.rebase false

## Set git name and email
defgitname=$(hostname)
defgitemail="$(hostname)@collinsoft.com"

read -p "Name for git (${defgitname}): " gitname
read -p "Email for git (${defgitemail}): " gitemail
gitname="${gitname:-$defgitname}"
gitemail="${gitemail:-$defgitemail}"

git config --global user.name "${gitname}"
git config --global user.email "${gitemail}"

echo "Set up dotfiles..."
. setupdotfiles.sh

read -p "Install Nix? " i
if [ "$i" == "y" ]; then
    . nixbootstrap.sh
fi

read -p "Install fzf? " i
if [ "$i" == "y" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
fi

read -p "Install zoxide? " i
if [ "$i" == "y" ]; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

read -p "Install kitty? " i
if [ "$i" == "y" ]; then
    #sudo apt install kitty
    cd "${HOME}/.config"
    git clone https://${git_key}@git.collinsoft.com/goz/kitty.git
    mkdir -p  "${HOME}/.local/share/applications"
    cd ${HOME}/.config/kitty
    bash install-kitty.sh
fi

echo "Set up Vim..."
if [ ! -d ~/.vim ]; then
    git clone --quiet git@github.com:mrrcollins/vim.git ~/.vim
    cd ~/.vim
    . bootstrap.sh
else
    echo "~/.vim already exists..."
fi

echo "Clone Espanso"
if [[ "$ostype" =~ "Darwin" ]]; then
    ./macosEspanso.sh
fi

if [[ "${ostype}" =~ "Linux" ]]; then
    read -p "Install espanso? " i
    if [ "${i}" == "y" ]; then
        if [ ! -d ~/.config/espanso ]; then
            git clone --quiet git@github.com:mrrcollins/espanso.git ~/.config/espanso

            cd "/tmp"
            wget https://github.com/federico-terzi/espanso/releases/latest/download/espanso-debian-${XDG_SESSION_TYPE}-amd64.deb
            sudo apt install ./espanso-debian-${XDG_SESSION_TYPE}-amd64.deb
            espanso service register
            espanso start
        else
            echo "~/.config/espanso already exists..."
        fi
        
    fi
fi

cd ~

