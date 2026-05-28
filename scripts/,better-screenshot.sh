#!/bin/bash
#

attach="/home/goz/.config/dotfiles/scripts/attachments.sh"

while getopts s:b: flag
do
    case "${flag}" in
        s) screenshot=${OPTARG};;
        b) background=${OPTARG};;
    esac
done
#screenshot="installapp.jpg"

[ -z "${screenshot}" ] && { echo "I need a file to work with!"; exit; }

[ -z "${background}" ] || [ ! -f "${background}" ] && background="/tmp/2024-03-30-e-tiled-background.png"

tmpshot="/tmp/tmpshot.png"
workback="/tmp/back.png"
tback="/tmp/tback.png"
output="/tmp/finished.png"

shotwidth=$(identify -format "%w" "${screenshot}")
shotheight=$(identify -format "%h" "${screenshot}")

backwidth=$((${shotwidth} + 100))
backheight=$((${shotheight} + 100))

#echo "Working with ${screenshot} (${shotwidth}x${shotheight}) on ${background}"

#create a tiled background the size we need
convert "${background}" -gravity center -crop ${backwidth}x${backheight}+0+0 +repage "${workback}"

#Round the background corners
convert "${workback}" \
    \( +clone -alpha extract \
    -draw 'fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0' \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \
    \) -alpha off -compose CopyOpacity -composite "${workback}"

#Round the screenshot corners
convert "${screenshot}" \
    \( +clone -alpha extract \
    -draw 'fill black polygon 0,0 0,15 15,0 fill white circle 15,15 15,0' \
    \( +clone -flip \) -compose Multiply -composite \
    \( +clone -flop \) -compose Multiply -composite \
    \) -alpha off -compose CopyOpacity -composite "${tmpshot}"

# Add drop shadow to screenshot
convert "${tmpshot}" \
    \( +clone -background black -shadow 40x5+0+0 \) \
    +swap -background none -layers merge +repage "${tmpshot}"

# Create final image
convert -size ${backwidth}x${backheight} xc:transparent "PNG32:${tback}"
    composite -gravity center "${workback}" "${tback}" "${output}"
    composite -gravity center "${tmpshot}" "${output}" "${output}"

rm "${tback}" "${workback}" "${tmpshot}"
sendfile="/tmp/"$(date +"%Y-%m-%d")"-${screenshot%.*}.png"
mv "${output}" "${sendfile}"
#echo "${sendfile}"
/usr/local/bin/telegram-send --disable-web-page-preview --silent -i "${sendfile}"

# Create attachment too
dest=$(${attach} "${sendfile}" e)

/usr/local/bin/telegram-send --disable-web-page-preview --silent "${dest}"
/usr/local/bin/telegram-send --disable-web-page-preview --silent "![${screenshot%.*}](${dest})"


