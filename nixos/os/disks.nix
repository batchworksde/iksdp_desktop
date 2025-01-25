{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = lib.mkMerge [
            ({
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  extraArgs = [ "-F" "32" "-n" "iksdp-BOOT" ];
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              swap = {
                size = "2G";
                content = {
                  type = "swap";
                  resumeDevice = true;
                  priority = 1;
                };
              };
              nix = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = [ "-L" "iksdp-nix" "-T" "news" "-m" "1" ];
                  mountpoint = "/nix";
                  mountOptions = [ "defaults" ];
                };
              };
            })
            (lib.mkIf (config.persistence.type == "impermanence") {
              root = {
                size = "8G";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  extraArgs = [ "-L" "iksdp-root" "-T" "news" "-m" "1" ];
                  mountpoint = "/";
                  mountOptions = [ "defaults" ];
                };
              };
            })
          ];
        };
      };
    };
    nodev = lib.mkMerge [
    (lib.mkIf (config.persistence.type == "impermanence") 
    {
      tmp = {
        fsType = "tmpfs";
        mountpoint = "/tmp";
        mountOptions = [
          "size=50%"
        ];
      };
    })
    (lib.mkIf (config.persistence.type == "preservation") 
      {
        root = {
          fsType = "tmpfs";
          mountpoint = "/";
          mountOptions = [
            "defaults"
            "size=50%"
          ];
        };
      })
    ];
  };

  fileSystems = {
    livehome = {
      device = "/dev/disk/by-label/iksdp-home";
      label = "iksdp-home";
      mountPoint = "/home/live";
      fsType = "ext4";
      options = [ 
        "nofail" 
        "x-systemd.device-timeout=5s" 
      ];
    };
  };
}
