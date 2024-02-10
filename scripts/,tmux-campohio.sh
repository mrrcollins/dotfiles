#!/bin/bash

session="Dreamhost"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n gozgeek "ssh gozgeek"
tmux move-window -t 5

tmux new-window -n bw "ssh bw"
tmux move-window -t 6

tmux new-window -n blacksorchard "ssh blacksorchard"
tmux move-window -t 7

tmux new-window -n campohio "ssh campohio"
tmux move-window -t 8

tmux new-window

echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

