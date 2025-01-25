{ config, lib, pkgs, ... }:

{
  # https://nixos.wiki/wiki/Printing
  services.printing.enable = true;

  # Autodiscovery (AirPrint)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
