#!/bin/bash

session="racknerd"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n dcb824 "ssh dcb824"
tmux move-window -t 5

tmux new-window -n d363a9 "ssh d363a9"
tmux move-window -t 6

tmux new-window -n 4c9a56 "ssh 4c9a56"
tmux move-window -t 7

tmux new-window -n egon "ssh egon"
tmux move-window -t 8

tmux new-window -n 7e9720 "ssh 7e9720"
tmux move-window -t 9

tmux new-window -n wg "ssh wg"
tmux move-window -t 10

tmux new-window

echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

