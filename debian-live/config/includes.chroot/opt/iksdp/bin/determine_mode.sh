#!/bin/bash

# Script to check if /home is directly mounted from a device

# Get the mount information for /home
mount_info=$(findmnt -n -o SOURCE,TARGET /home)

if [[ -n "$mount_info" ]]; then
    source=$(echo "$mount_info" | awk '{print $1}')
    target=$(echo "$mount_info" | awk '{print $2}')
    
    if [[ "$target" == "/home" ]]; then
        echo "persistent" > /tmp/iksdp_mode
    fi
else
    echo "non-persistent" > /tmp/iksdp_mode
fi