{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./boot.nix
    ./disks.nix
    ./hardware.nix
    ./swap.nix
    ./persistence.nix
    ./locale.nix
    ./network.nix
    ./printing.nix
    ./update.nix
  ];
    
  time.timeZone = "Africa/Nairobi";
  environment.variables.EDITOR = "vim";

  documentation = {
    enable = true;
    nixos.enable = true;
    man.enable = true;
    info.enable = true;
    doc.enable = true;
    dev.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = 2;
    };
  };

  # do not use, it is currently not stable enough
  # persistence.type = "preservation";
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
