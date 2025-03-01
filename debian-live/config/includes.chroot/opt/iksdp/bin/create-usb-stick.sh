#!/bin/bash

# Ensure that the user is running the script with sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# List only USB devices with an index number
while IFS= read -r line; do
  usb_devices+=("$line")
done < <(lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "sd.*|sr.*" | grep -i usb | nl -v 1 | awk '{print $1" - /dev/"$2" "$3" "$4}')

# Check if at least one device is available
if [ -z "$usb_devices" ]; then
  echo "No suitable USB devices found! Connect a device and start the script again."
  exit 0
fi

# Show available USB devices with an index number
echo "Available USB devices:"
for device in "${usb_devices[@]}"; do
  echo "$device"
done

# Ask the user to choose a device by number
read -p "Enter the number of the device you want to use: " device_number
if [[ ! "$device_number" =~ ^[0-9]+$ ]] && [ ! "$device_number" -le "${#usb_devices[@]}" ]; then
  echo "The number you gave is not valid: $device_number"
  exit 1
fi

# Extract the device name based on the chosen number
usb_device=$(echo "${usb_devices[$device_number-1]}" | awk '{print $3}')

# Verify the device exists
if [ ! -b "$usb_device" ]; then
  echo "Invalid device: $usb_device"
  exit 1
fi

# Display a warning about data loss
echo "WARNING: All data on $usb_device will be erased!"
echo "The script can only proceed if the device is unmounted."
read -p "Are you sure you want to proceed? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Operation aborted. No changes were made."
  exit 0
fi

# Check if the device is already mounted
mounted=$(lsblk "$usb_device" -o MOUNTPOINT | grep -v MOUNTPOINT)

if [ -n "$mounted" ]; then
  echo "The device $usb_device is currently mounted at the following locations:"
  echo "$mounted"
  read -p "Do you want to unmount it before proceeding? (y/n): " unmount_choice
  if [[ "$unmount_choice" == "y" || "$unmount_choice" == "Y" ]]; then
    for mount_point in $mounted; do
      echo "Unmounting $mount_point..."
      umount "$mount_point"
    done
  else
    echo "The device must be unmounted before proceeding. Aborting."
    exit 1
  fi
fi

# Get the default size for the first partition (default: 1GB)
read -p "Enter size for the first partition (in MB, default 1024): " first_partition_size
first_partition_size=${first_partition_size:-1024}

# Ask if the user wants to encrypt the second partition
read -p "Do you want to encrypt the second partition with LUKS? (y/n): " encrypt_choice
if [[ "$encrypt_choice" == "y" || "$encrypt_choice" == "Y" ]]; then
  encrypt=true
else
  encrypt=false
fi

# Create the partition table and partitions with parted
echo "Creating partition table and partitions on $usb_device..."
/usr/sbin/parted "$usb_device" --script mklabel msdos

# Create the first partition (exFAT, with label 'Media')
/usr/sbin/parted "$usb_device" --script mkpart primary NTFS 1M "${first_partition_size}M"

# Create the second partition using the remaining space (ext4 or encrypted)
/usr/sbin/parted "$usb_device" --script mkpart primary ext4 "${first_partition_size}M" 100%

# Inform the user that the partitions have been created
echo "Partitions created. Now formatting..."

# Format the first partition as exFAT and set the label to 'Media'
/usr/sbin/mkfs.exfat -n "Media" "${usb_device}1"

if [ "$encrypt" == true ]; then
  # Encrypt the second partition with LUKS
  echo "Encrypting the second partition with LUKS..."
  /usr/sbin/cryptsetup luksFormat "${usb_device}2"

  # Open the LUKS encrypted partition
  echo "You have to specify the password once more to prepare the filesystem..."
  /usr/sbin/cryptsetup luksOpen "${usb_device}2" persistence

  # Format the LUKS-encrypted partition as ext4
  /usr/sbin/mkfs.ext4 /dev/mapper/persistence

  # Set the label of the encrypted partition to "persistence"
  /usr/sbin/e2label /dev/mapper/persistence "persistence"

  # Create the directory and persistence.conf file
  mkdir -p /mnt/usb2
  mount /dev/mapper/persistence /mnt/usb2
  echo "/home union" > /mnt/usb2/persistence.conf
  echo "/etc/iksdp_persistent union" >> /mnt/usb2/persistence.conf
  umount /mnt/usb2

  # Close the LUKS container (optional, depends on usage)
  /usr/sbin/cryptsetup luksClose persistence

else
  # Format the second partition as ext4 (no encryption)
  /usr/sbin/mkfs.ext4 "${usb_device}2"

  # Set the label of the second partition to "persistence"
  /usr/sbin/e2label "${usb_device}2" "persistence"

  # Create the directory and persistence.conf file
  mkdir -p /mnt/usb2
  mount "${usb_device}2" /mnt/usb2
  echo "/home union" > /mnt/usb2/persistence.conf
  echo "/etc/iksdp_persistent union" >> /mnt/usb2/persistence.conf
  umount /mnt/usb2
fi
