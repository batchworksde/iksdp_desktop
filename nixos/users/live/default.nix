{ config, lib, pkgs, ... }:

{ 
  users = {
    users = {
      live = {
        isNormalUser = true;
        password = "live";
        shell = pkgs.bashInteractive;
        uid = 1000;
        group = "live";
        extraGroups = [ "wheel" ];
      };
    };
    groups.live = {};
  };
}
