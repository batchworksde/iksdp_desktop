{ config, lib, pkgs, ... }:

{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos#${config.hostname}";
    flags = [ "--update-input" "nixpkgs" ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  nix = {
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    extraOptions = ''
      min-free = ${toString (1024 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
    '';
  };
}
