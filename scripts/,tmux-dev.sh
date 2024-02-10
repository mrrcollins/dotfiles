#!/bin/bash

session="developer"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n Net "ssh caddy"
tmux move-window -t 10

# Net


# set up Srvs window
tmux new-window -n Srvs "ssh db"
tmux move-window -t 11

# Srvs
#tmux send-keys -t 11 "ssh db" C-m
cmd="ssh gitea";splitw
cmd="ssh mealie";splitw
cmd="ssh xbrowsersync";splitw
cmd="ssh web";splitw
cmd="ssh pihole";splitw
cmd="ssh plex";splitw
cmd="ssh emasto";splitw

# Machines
tmux new-window -n Machines "ssh mini"
tmux move-window -t 12

cmd="ssh gozpro";splitw
cmd="ssh freenas";splitw

# ChicagoVPS
tmux new-window -n Machines "ssh buffalo"
tmux move-window -t 13

cmd="ssh dallas";splitw
cmd="ssh sanjose";splitw

# Racknerd
tmux new-window -n Machines "ssh buffalo"
tmux move-window -t 14

cmd="ssh dallas";splitw
cmd="ssh sanjose";splitw




echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

