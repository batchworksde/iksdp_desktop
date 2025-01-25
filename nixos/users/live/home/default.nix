{ config, pkgs, home-manager, lib, ... }:

{
  programs.home-manager.enable = true;

  home = {
    username = "live";
    homeDirectory = lib.mkForce "/home/live";
    stateVersion = "24.11";
  };

  # https://nix-community.github.io/home-manager/options.xhtml
  imports = [ 
    ./bash.nix
    ./gnome.nix
    ./firefox.nix
  ];
}
