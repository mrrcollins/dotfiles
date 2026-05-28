#!/bin/bash

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

cpconf="${HOME}/.ssh/rclone.d/cp.conf"

if [ -f "${cpconf}" ]; then
	source "${cpconf}"
else
	echo "${cpconf} not found, aborting..."
	exit 1
fi

if [ ! -f /usr/bin/rclone ]; then
	echo "Installing rclone..."
	sudo -v ; curl https://rclone.org/install.sh | sudo bash
fi

[ ! -d "${HOME}/Documents/cp" ] && mkdir -p "${HOME}/Documents/cp"

#/usr/bin/rclone -q ls cp: | less
/usr/bin/rclone -q mount cp: ${HOME}/Documents/cp ${defaults} 
