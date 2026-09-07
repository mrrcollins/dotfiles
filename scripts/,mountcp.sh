#!/bin/bash

ostype=$(uname -a)

if [[ "$ostype" =~ "Darwin" ]]; then
    RCLONE="/usr/local/bin/rclone"
else
    RCLONE="/usr/bin/rclone"
fi

# rclone defaults
defaults="\
    --links \
    --allow-non-empty \
    --cache-workers=8 \
    --cache-writes \
    --no-modtime \
    --drive-use-trash \
    --stats=0 \
    --checkers=16 \
    --vfs-cache-mode full \
    --vfs-cache-max-size 1G \
	--daemon" 

# Store CopyParty webdav credentials in .ssh 
# so I don't have to do rclone config on
# every machine
cpconf="${HOME}/.ssh/rclone.d/cp.conf"

if [ -f "${cpconf}" ]; then
	source "${cpconf}"
else
	echo "${cpconf} not found, aborting..."
	exit 1
fi

# Check for rclone, if not installed, install it
if [ ! -f ${RCLONE} ]; then
	echo "Installing rclone..."
	sudo -v ; curl https://rclone.org/install.sh | sudo bash
fi

[ ! -d "${HOME}/Documents/cp" ] && mkdir -p "${HOME}/Documents/cp"

# Mount CopyParty under Documents
${RCLONE} -q mount cp: ${HOME}/Documents/cp ${defaults} 
