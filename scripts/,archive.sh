#!/bin/bash

if [ $# -eq 0 ]; then
        >&2 echo "No arguments provided"
        exit 1
fi

file=${1}
y=$(date +"%Y")
dest="${HOME}/notes/Archive/${y}"

[ ! -d "${dest}" ] && mkdir -p "${dest}"

git mv "${file}" "${dest}/"

