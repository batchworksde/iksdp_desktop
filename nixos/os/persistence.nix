{ config, lib, pkgs, impermanence, preservation, ... }:

{
  environment.persistence = {
    persistence = {
      enable = lib.mkIf (config.persistence.type != "impermanence") false;
      persistentStoragePath = "/nix/persistence";
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };

  preservation = {
    enable = lib.mkIf (config.persistence.type == "preservation") true;
    preserveAt.persistence = {
      persistentStoragePath = "/nix/persistence";
      directories = [
        "/etc/nixos"
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        { 
          file = "/etc/machine-id";
          user = "root";
          group = "root";
          mode = "0644";
          inInitrd = true; 
          how = "symlink"; 
        }
        { 
          file = "/etc/shadow";
          user = "root";
          group = "shadow";
          mode = "0640";
          inInitrd = true; 
          how = "bindmount";
        }
        { 
          file = "/etc/group";
          user = "root";
          group = "root";
          mode = "0644";
          inInitrd = true; 
          how = "bindmount";
        }
      ];
    };
  };

  boot.initrd.preLVMCommands = lib.mkIf (config.persistence.type != "preservation") ''
      WAIT_TIME=5
      MAX_RETRIES=6
      ROOT_DEV="/dev/disk/by-label/iksdp-root"

      mountPartition() {
        echo "mount the root / partition"

        echo "create the /iksdp-root folder"
        mkdir -p /iksdp-root

        COUNTER=1
        while [ ! -e "$ROOT_DEV" ] || [ ! -e "/iksdp-root" ]; do
          echo "the root partition or the mount folder are not yet available"
          sleep $WAIT_TIME
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "device check failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done

        COUNTER=1
        until mount "$ROOT_DEV" /iksdp-root; do
          echo "the root partition has not yet been mounted"
          sleep "$WAIT_TIME"
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "mount failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done
        echo "mount done"
      }

      wipePartition() {
        echo "wipe the content from the / partition"

        COUNTER=1
        until rm -rf "/iksdp-root/*"; do
          echo "the wipe has been failed"
          sleep 5
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "wipe failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done
        echo "wipe done"
      }

      umountPartition() {
        echo "umount the root / partition"

        COUNTER=1
        until umount "/iksdp-root"; do
          echo "umount failed"
          sleep 5
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "umount failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done
        echo "umount done"
      }

      loadModules() {
        echo "load the ext4 module"

        COUNTER=1
        until modprobe ext4; do
          echo "modprobe ext4 failed"
          sleep 5
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "modprobe failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done
        echo "modprobe done"
      }

      fixPermissions() {
        echo "fix /var/empty permissions"

        COUNTER=1
        until chattr -i -a "/iksdp-root/var/empty"; do
          echo "chattr /var/empty failed"
          sleep 5
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "chattr failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done

        COUNTER=1
        until chmod 755 "/iksdp-root/var/empty"; do
          echo "chmod /var/empty failed"
          sleep 5
          if [ "$COUNTER" -eq "$MAX_RETRIES" ]; then
            echo "chmod failed"
            exit 1
          fi
          COUNTER="$((COUNTER + 1))"
        done
        echo "permissions fix done"
      }

      loadModules
      mountPartition
      fixPermissions
      wipePartition
      umountPartition
  '';
}