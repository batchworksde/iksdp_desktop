{ config, lib, pkgs, ... }:

{
  imports =
  [
    ./root/default.nix
    ./live/default.nix
  ];

  users = {
    mutableUsers = false;
  };
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
}
