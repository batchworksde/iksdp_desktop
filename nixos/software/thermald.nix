{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    thermald
  ];
  services.thermald.enable = true;
}
