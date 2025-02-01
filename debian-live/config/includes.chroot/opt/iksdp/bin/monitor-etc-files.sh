#!/bin/bash

FILES_TO_MONITOR=("/etc/shadow" "/etc/hosts" "/etc/hostname")
PERSISTENT_DIR="/etc/iksdp_persistent"

# get the mount information for /etc/iksdp_persistent
mount_info=$(findmnt -n -o TARGET /etc/iksdp_persistent)
if [[ -n "$mount_info" ]]; then
    # copy files and monitor change when in /etc/iksdp_persistent in persistent mode
    if [[ "$mount_info" == "/etc/iksdp_persistent" ]]; then
        # replace system files with persistent files
        if [ -d "${PERSISTENT_DIR}" ]; then
            echo "copy persistent files back to /etc"
            for file in "${FILES_TO_MONITOR[@]}"; do
                if [ -f "$PERSISTENT_DIR/$(basename $file)" ]; then
                    echo "copy $PERSISTENT_DIR/$(basename $file) to $file"
                    cp "$PERSISTENT_DIR/$(basename $file)" "$file"
                fi
            done
        fi

        # monitor the files for changes
        inotifywait --monitor --event delete_self,modify "${FILES_TO_MONITOR[@]}" | while read -r path action file
        do
            # get the full path of the modified file
            FILE="$path$file"
                
            # copy the file to the persistent directory
            echo "copy $FILE to persistent folder ($PERSISTENT_DIR/$(basename $FILE))"
            cp "$FILE" "$PERSISTENT_DIR/$(basename $FILE)"
        done
    else
        echo "/etc/iksdp_persistent not used in persistence mode, stop systemd service"
        exit 0
    fi
else
    echo "/etc/iksdp_persistent not used in persistence mode, stop systemd service"
    exit 0
fi
