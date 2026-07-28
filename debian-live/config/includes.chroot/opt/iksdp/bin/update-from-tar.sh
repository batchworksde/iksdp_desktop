#!/bin/bash

TAR_FILE="$HOME/debian-live.tar.tar"
EFI_PARTITION_NAME="EFI"
IKSDP_PARTITION_NAME="IKSDP"
while [[ $# -gt 0 ]]; do
    case $1 in
        --tar)
            TAR_FILE="$2"
            shift 2
            ;;
        --efi)
            EFI_PARTITION_NAME="$2"
            shift 2
            ;;
        --iksdp)
            IKSDP_PARTITION_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--tar $HOME/debian-live.tar.tar] [--efi EFI] [--iksdp IKSDP]"
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

# check for errors and get partitions
if [[ "$UPDATE_MODE" != true ]]; then
    echo "You are not in update mode! Please reboot and start in update mode."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
    echo "You do not have enough permissions! Please run as root."
    exit 1
fi

if [[ ! -f "$TAR_FILE" ]]; then
    echo "File $TAR_FILE not found! Specify the correct path with the parameter --tar."
    exit 1
fi

if ! tar -tf $TAR_FILE 2>/dev/null | grep -q "binary/EFI"; then
    echo "The file $TAR_FILE seems not to be valid! Check if you really specified the correct file (--tar)."
    exit 1
fi

EFI_PARTITION=$(findfs PARTLABEL=$EFI_PARTITION_NAME 2>/dev/null)
if [ "$?" -ne 0 ]; then
    echo "Partition with the label $EFI_PARTITION_NAME cannot be found! Check the name you specified (--efi)."
    exit 1
fi

IKSDP_PARTITION=$(findfs PARTLABEL=$IKSDP_PARTITION_NAME 2>/dev/null)
if [ "$?" -ne 0 ]; then
    echo "Partition with the label $IKSDP_PARTITION_NAME cannot be found! Check the name you specified (--iksdp)."
    exit 1
fi

# mount partitions
mkdir -p /media/p1 /media/p2
mount $EFI_PARTITION /media/p1 2>/dev/null
if [ "$?" -ne 0 ]; then
    echo "Error while mounting partition with the label $EFI_PARTITION_NAME! Check your partitions and filesystems."
    exit 1
fi
mount $IKSDP_PARTITION /media/p2 2>/dev/null
if [ "$?" -ne 0 ]; then
    echo "Error while mounting partition with the label $IKSDP_PARTITION_NAME! Check your partitions and filesystems."
    exit 1
fi

# extract data to partitions
read -p "Press Enter to update IKSDP desktop from the TAR file..."
echo

tar -xvf $TAR_FILE --directory /media/p1 --strip-components 1 binary/EFI
if [ "$?" -ne 0 ]; then
    echo "Error while extracting files to the partition with the label $EFI_PARTITION_NAME! Update might have failed."
    exit 1
fi
tar --exclude='binary/EFI' -xvf $TAR_FILE --directory /media/p2 --strip-components 1
if [ "$?" -ne 0 ]; then
    echo "Error while extracting files to the partition with the label $IKSDP_PARTITION_NAME! Update might have failed."
    exit 1
fi

# unmount partitions
umount /media/p1 2>/dev/null
if [ "$?" -ne 0 ]; then
    echo "Error while unmounting partition with the label $EFI_PARTITION_NAME! Update might have failed."
    exit 1
fi

umount /media/p2 2>/dev/null
if [ "$?" -ne 0 ]; then
    echo "Error while unmounting partition with the label $IKSDP_PARTITION_NAME! Update might have failed."
    exit 1
fi

# last message
echo "Update completed! Please reboot."
exit 0
