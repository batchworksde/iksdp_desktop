{ config, lib, pkgs, ... }:

{
  # https://nixos.wiki/wiki/Printing
  services.printing.enable = true;

  # Autodiscovery (AirPrint) is provided by services.resolved.enable
}
