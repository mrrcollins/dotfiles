#!/bin/bash

# Mount gozvault
/usr/bin/rclone mount obsidian-b2:rc-obsidian/gozvault /home/goz/gozvault \
        --daemon \
        --allow-other \
        --uid 1000 \
        --vfs-cache-mode full \
        --vfs-fast-fingerprint \
        --cache-dir /var/cache/rclone/gozvault \
        --no-modtime \
        --vfs-cache-max-size 10G \
        --vfs-cache-max-age 168h
