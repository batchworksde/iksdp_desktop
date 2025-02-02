{ config, lib, pkgs, ... }:

{
  imports =
  [
    ./root/default.nix
    ./live/default.nix
  ];

  users = {
    mutableUsers = true;
  };
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
}
