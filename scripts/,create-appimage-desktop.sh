#!/bin/bash

# From:
# [.desktop - How can I create a desktop entry for an AppImage? - Ask Ubuntu](https://askubuntu.com/questions/1328196/how-can-i-create-a-desktop-entry-for-an-appimage)
#

set -e
set -o pipefail

APPIMAGE_PATH=$1

if [ -z "$APPIMAGE_PATH" ]; then
    echo "Missing argument: appimage"
    exit 1
fi

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "File not found: $APPIMAGE_PATH"
    exit 1
fi

TEMP_SQUASHFS_PATH=$(mktemp -d)
APPIMAGE_FULLPATH=$(readlink -e "$APPIMAGE_PATH")
APPIMAGE_FILENAME=$(basename "$APPIMAGE_PATH")
APP_NAME="${APPIMAGE_FILENAME%.*}"
DESKTOP_ENTRY_PATH="${HOME}/.local/share/applications/$APP_NAME.desktop"
ICON_FOLDER="${HOME}/.local/share/icons"
mkdir -p "${ICON_FOLDER}"

if [ "$2" == "--remove" ]; then
    rm -f "$DESKTOP_ENTRY_PATH"
    find "${ICON_FOLDER}" -maxdepth 1 -type f -name "$APP_NAME.*" -delete
    echo "Removed"
    exit 0
fi

pushd $TEMP_SQUASHFS_PATH
"$APPIMAGE_FULLPATH" --appimage-extract > /dev/null
cd squashfs-root/

echo "Choose icon: "
mapfile -t FILENAMES < <(find -L . -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.svg' \))
i=1
for filename in "${FILENAMES[@]}"
do
    printf " %d) %s\n" "$i" "$filename"
    i=$((i + 1))
done

read -r SELECTED_INDEX

ICON_SRC=${FILENAMES[$((SELECTED_INDEX - 1))]}
ICON_EXT="${ICON_SRC##*.}"
ICON_DST="${ICON_FOLDER}/$APP_NAME.$ICON_EXT"
cp "$ICON_SRC" "$ICON_DST"

cat <<EOT > "$DESKTOP_ENTRY_PATH"
[Desktop Entry]
Name=$APP_NAME
StartupWMClass=$APP_NAME
Exec="$APPIMAGE_FULLPATH"
Icon=$ICON_DST
Type=Application
Terminal=false
EOT

popd

rm -rf $TEMP_SQUASHFS_PATH

echo "Created"

