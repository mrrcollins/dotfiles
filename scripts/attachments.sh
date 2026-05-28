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
#url["rc"]="https://f000.backblazeb2.com/file/ryancollins-org/attachments/${y}"
#url["rc"]="https://cdn.collinsoft.com/file/cdn-collinsoft/ryancollins-org/${y}"
url["rc"]="https://dl.ryancollins.org/${y}"
#url["e"]="https://cdn.collinsoft.com/file/cdn-collinsoft/eduk8.me/${y}"
url["e"]="https://files.eduk8.me/${y}"
url["gg"]="https://cdn.gozgeek.com/${y}"

#echo "URL "${url["${dest}"]}

shortname=$(basename "${file%.*}")
slug=$(echo "${shortname}" | tr '[:upper:]' '[:lower:]' | sed -e 's/ /-/g' -e 's/[^a-z0-9-]//g')
name="${d}-${slug}"
ext="${file##*.}"
out="/tmp/attachments/${name}"
mkdir -p "${out}"

cp "${file}" "${out}/${name}.$ext"
${convert} "${file}" -resize 150x150 "${out}/${slug}-150x.${ext}"
${convert} "${file}" -resize 1024x768 "${out}/${slug}-1024x.${ext}"
${convert} "${file}" -resize 2048x1536 "${out}/${slug}-2048x.${ext}"

#remote["rc"]="rcorg:ryancollins-org/attachments/${y}/${name}"
remote["rc"]="b2gg:cdn-collinsoft/ryancollins-org/${y}"
remote["e"]="b2gg:cdn-collinsoft/eduk8.me/${y}"
remote["gg"]="b2gg:cdn-collinsoft/gozgeek.com/${y}"

#echo "Remote "${remote["${dest}"]}

${rclone} copy "${out}" ${remote["${dest}"]}
echo ${url["${dest}"]}"/${slug}-1024x.${ext}"

# Clean up!
rm -R "${out}"

