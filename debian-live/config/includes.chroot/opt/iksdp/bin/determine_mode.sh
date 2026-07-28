#!/bin/bash

# Script to check if /home is directly mounted from a device

# Get the mount information for /home
mount_info=$(findmnt -n -o SOURCE,TARGET /home)

# get username
LIVE_CONFIG_CMDLINE="${LIVE_CONFIG_CMDLINE:-$(cat /proc/cmdline)}"
for _PARAMETER in ${LIVE_CONFIG_CMDLINE}
do
    case "${_PARAMETER}" in
        live-config.username=*|username=*)
            LIVE_USERNAME="${_PARAMETER#*username=}"
            ;;
        toram)
            UPDATE_MODE="U"
            ;;
    esac
done

if [[ -n "$mount_info" ]]; then
    source=$(echo "$mount_info" | awk '{print $1}')
    target=$(echo "$mount_info" | awk '{print $2}')
    
    if [[ "$target" == "/home" ]]; then
        PERSISTENCE="persistent"
    fi
else
    PERSISTENCE="non-persistent"

    # install keyring with empty password
    if [ -n ${LIVE_USERNAME+x} ]; then
        install -d /home/"${LIVE_USERNAME}"/.local/share/keyrings/
        install -o "${LIVE_USERNAME}" -g "${LIVE_USERNAME}" -m 644 /opt/iksdp/template/.local/share/keyrings/default /home/"${LIVE_USERNAME}"/.local/share/keyrings
        install -o "${LIVE_USERNAME}" -g "${LIVE_USERNAME}" -m 600 /opt/iksdp/template/.local/share/keyrings/Default_keyring.keyring /home/"${LIVE_USERNAME}"/.local/share/keyrings
    fi
fi

if [ -n "$UPDATE_MODE" ]; then
    PERSISTENCE+=" $UPDATE_MODE"
fi

echo "$PERSISTENCE" > /tmp/iksdp_mode
