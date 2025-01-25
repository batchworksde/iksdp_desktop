{ config, lib, pkgs, ... }:

{
  options = {
    hostname = lib.mkOption {
      type = lib.types.str;
      example = "pc-1";
      description = "config.hostname to define the hostname of the configured object";
    };
    network.interface = lib.mkOption {
      type = lib.types.str;
      example = "enp1s0";
      description = "config.network.interface to define the network interface";
    };
    bootloader.type = lib.mkOption {
      type = lib.types.str;
      example = "grub";
      default = "systemd";
      description = "config.bootloader.type[grub|systemd] to define the to be used bootloader";
    };
    persistence.type = lib.mkOption {
      type = lib.types.str;
      example = "preservation";
      default = "impermanence";
      description = "config.persistence.type[impermanence|preservation] to define the to be used persistence provider";
    };
  };
}
