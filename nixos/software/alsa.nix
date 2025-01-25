{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    alsa-tools
    alsa-utils
  ];
}
