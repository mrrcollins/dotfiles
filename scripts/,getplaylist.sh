#!/bin/bash

URL="${1}"
ytdlp="${HOME}/.local/bin/yt-dlp"

PLAYLIST_TITLE=$(${ytdlp} -o "%(playlist_title)s" --no-flat-playlist --max-downloads 1 --get-filename "${URL}")

echo "Making folder for ${PLAYLIST_TITLE}"
mkdir "${PLAYLIST_TITLE}"
cd "${PLAYLIST_TITLE}"

echo "Downloading playlist..."
${ytdlp} -x -o "%(title)s.%(ext)s" "${URL}"

echo "Creating playlist file..."
${ytdlp} -s --flat-playlist --print-to-file "%(title)s.opus" "%(playlist_title)s.m3u" "${URL}"

new_playlist="AA-${PLAYLIST_TITLE}.m3u"

awk -v prefix="/Playlists/${PLAYLIST_TITLE}/" '
  /^#/ || /^$/ { print; next }
  { print prefix $0 }
' "${PLAYLIST_TITLE}.m3u" > "$new_playlist"

