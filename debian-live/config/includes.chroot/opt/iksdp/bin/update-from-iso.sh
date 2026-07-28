#!/bin/bash

FORCE=false
DISK_DEVICE="/dev/nvme0n1"
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --disk)
            DISK_DEVICE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--force] [--disk /dev/sdX]"
            exit 1
            ;;
    esac
done

LIVE_CONFIG_CMDLINE="${LIVE_CONFIG_CMDLINE:-$(cat /proc/cmdline)}"
for _PARAMETER in ${LIVE_CONFIG_CMDLINE}
do
    case "${_PARAMETER}" in
        live-config.username=*|username=*)
            LIVE_USERNAME="${_PARAMETER#*username=}"
            ;;
        toram)
            UPDATE_MODE=true
            ;;
    esac
done

if [ -f /etc/iksdp_version ]; then
    LOCAL_IKSDP_VERSION=$(< /etc/iksdp_version)
else
    echo "/etc/iksdp_version not found"
    exit 1
fi

MD5_URL=$(
    curl -s https://api.github.com/repos/batchworksde/iksdp_desktop/releases/latest |
    jq -r '.assets[] | select(.name | endswith("iso.md5.txt")) | .browser_download_url'
)
ISO_URL=$(
    curl -s https://api.github.com/repos/batchworksde/iksdp_desktop/releases/latest | 
    jq -r '.body' | grep -Eo 'https?://[^ ]+\.iso' | 
    head -n 1
)
REMOTE_MD5=$(curl -sL $MD5_URL | head -n1 | awk '{print $1}')
REMOTE_ISO_PATH=$(curl -sL $MD5_URL | head -n1 | awk '{print $2}')

if [[ $REMOTE_ISO_PATH =~ ([0-9]+\.[0-9]+\.[0-9]+-[0-9]{14}) ]]; then
    REMOTE_IKSDP_VERSION="${BASH_REMATCH[1]}"
fi

if [[ "$LOCAL_IKSDP_VERSION" == "$REMOTE_IKSDP_VERSION" && "$FORCE" == false ]]; then
    echo "You already use the latest version $REMOTE_IKSDP_VERSION. No update needed (use --force to override)."
    exit 0
fi

if [[ "$UPDATE_MODE" != true ]]; then
    echo "You are not in update mode! Please reboot and start in update mode."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "You do not have enough permissions! Please run as root."
    exit 1
fi

ISO_NAME="/home/${LIVE_USERNAME}/iksdp-update/debian-live.iso"
ISO_DIRECTORY="$(dirname "$ISO_NAME")"
if [[ ! -d "$ISO_DIRECTORY" ]]; then
    mkdir -p "$ISO_DIRECTORY"
fi

if [[ -f "$ISO_NAME" ]]; then
    echo "Local ISO found. Verifying MD5..."

    LOCAL_MD5=$(md5sum "$ISO_NAME" | awk '{print $1}')
    echo "Local MD5: $LOCAL_MD5"
    echo "Remote MD5: $REMOTE_MD5"

    if [[ "$LOCAL_MD5" == "$REMOTE_MD5" ]]; then
        echo "ISO is already up-to-date. No download needed."
        DOWNLOAD_ISO=false
    else
        echo "MD5 mismatch -> re-downloading ISO..."
        DOWNLOAD_ISO=true
    fi
else
    DOWNLOAD_ISO=true
fi

if [[ "$DOWNLOAD_ISO" == true ]]; then
    echo "Downloading ISO..."
    rm -f "$ISO_NAME"
    curl -L -o "$ISO_NAME" "$ISO_URL"

    LOCAL_MD5=$(md5sum "$ISO_NAME" | awk '{print $1}')
    if [[ "$LOCAL_MD5" == "$REMOTE_MD5" ]]; then
        echo "ISO downloaded correctly. MD5 verified."
    else
        echo "ERROR: Downloaded ISO checksum mismatch!"
        exit 1
    fi
fi

read -p "Press Enter to update IKSDP desktop from the ISO file..."
echo

dd if="$ISO_NAME" of=${DISK_DEVICE} status=progress
