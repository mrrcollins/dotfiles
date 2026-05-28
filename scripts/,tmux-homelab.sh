#!/bin/bash

session="homelab"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n Net "ssh caddy"
tmux move-window -t 3

tmux new-window -n db "ssh db"
tmux move-window -t 4

tmux new-window -n gitea "ssh gitea"
tmux move-window -t 5

tmux new-window -n mealie "ssh mealie"
tmux move-window -t 6

tmux new-window -n xb "ssh xbrowsersync"
tmux move-window -t 7

tmux new-window -n web "ssh web"
tmux move-window -t 8

tmux new-window -n pihole "ssh pihole"
tmux move-window -t 9

tmux new-window -n plex "ssh plex"
tmux move-window -t 10

tmux new-window -n emasto "ssh emasto"
tmux move-window -t 11

# Srvs
#tmux send-keys -t 11 "ssh db" C-m
#cmd="ssh gitea";splitw
#cmd="ssh mealie";splitw
#cmd="ssh xbrowsersync";splitw
#cmd="ssh web";splitw
#cmd="ssh pihole";splitw
#cmd="ssh plex";splitw
#cmd="ssh emasto";splitw

echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

