#!/bin/bash

session="chicagovps"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n buffalo "ssh buffalo"
tmux move-window -t 10

tmux new-window -n dallas "ssh dallas"
tmux move-window -t 11

tmux new-window -n sanjose "ssh sanjose"
tmux move-window -t 12

tmux new-window
tmux new-window
tmux new-window

echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

