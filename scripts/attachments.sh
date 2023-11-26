#!/bin/bash

convert="/usr/bin/convert"
rclone="/usr/bin/rclone"

d=$(date +"%Y-%m-%d")
file="${1}"
y=$(date +"%Y")
url="https://f000.backblazeb2.com/file/ryancollins-org/attachments/${y}"

name="${d}-"$(basename "${file%.*}")
ext="${file##*.}"
out="/tmp/${name}"
mkdir -p "${out}"

cp "${file}" "${out}/${name}.$ext"
${convert} "${file}" -resize 150x150 "${out}/${name}-150x.${ext}"
${convert} "${file}" -resize 1024x768 "${out}/${name}-1024x.${ext}"
${convert} "${file}" -resize 2048x1536 "${out}/${name}-2048x.${ext}"

${rclone} sync "${out}" "rcorg:ryancollins-org/attachments/${y}/${name}"
echo "${url}/${name}/${name}-1024x.${ext}"
