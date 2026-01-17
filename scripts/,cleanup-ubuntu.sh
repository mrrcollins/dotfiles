#!/bin/bash

sudo apt autoremove
sudo find /var/lib/snapd/cache/ -exec rm -v {} \;

set -eu
LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
	while read snapname revision; do
		sudo snap remove "$snapname" --revision="$revision"
	done

