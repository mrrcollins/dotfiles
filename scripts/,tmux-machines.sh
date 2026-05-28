#!/bin/bash

session="machines"
splitw () {
    tmux split-window -p 10 "${cmd}"
    tmux select-layout tiled
}

tmux start-server

# set up Net window
tmux new-session -d -s ${session} -n Mini "ssh mini"
tmux move-window -t 5

# Machines
tmux new-window -n gozpro "ssh gozpro"
tmux move-window -t 6

tmux new-window -n freenas "ssh freenas"
tmux move-window -t 7

tmux new-window -n ryzenmox "ssh proxmox-ryzen"
tmux move-window -t 8

tmux new-window -n lenovomox "ssh proxmox-lenovo"
tmux move-window -t 9

tmux new-window -n minimox "ssh proxmox-mini"
tmux move-window -t 10


echo "Attaching to ${session}..."
tmux new-window
tmux a -d -t ${session}

