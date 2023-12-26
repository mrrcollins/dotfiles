#!/bin/bash

declare -A url
declare -A remote

convert="/usr/bin/convert"
rclone="/usr/bin/rclone"
dest="${2}"

[ -z "${dest}" ] && dest="rc"

#echo "Destination: ${dest}"

d=$(date +"%Y-%m-%d")
file="${1}"
y=$(date +"%Y")
#url="https://f000.backblazeb2.com/file/ryancollins-org/attachments/${y}"
url["rc"]="https://f000.backblazeb2.com/file/ryancollins-org/attachments/${y}"
url["e"]="https://f000.backblazeb2.com/file/cdn-collinsoft/eduk8.me/${y}"

#echo "URL "${url["${dest}"]}

shortname=$(basename "${file%.*}")
slug=$(echo "${shortname}" | tr '[:upper:]' '[:lower:]' | sed -e 's/ /-/g' -e 's/[^a-z0-9-]//g')
name="${d}-${slug}"
ext="${file##*.}"
out="/tmp/${name}"
mkdir -p "${out}"

cp "${file}" "${out}/${name}.$ext"
${convert} "${file}" -resize 150x150 "${out}/${slug}-150x.${ext}"
${convert} "${file}" -resize 1024x768 "${out}/${slug}-1024x.${ext}"
${convert} "${file}" -resize 2048x1536 "${out}/${slug}-2048x.${ext}"

remote["rc"]="rcorg:ryancollins-org/attachments/${y}/${name}"
remote["e"]="b2gg:cdn-collinsoft/eduk8.me/${y}/${name}"

#echo "Remote "${remote["${dest}"]}

${rclone} sync "${out}" ${remote["${dest}"]}
echo ${url["${dest}"]}"/${name}/${slug}-1024x.${ext}"
