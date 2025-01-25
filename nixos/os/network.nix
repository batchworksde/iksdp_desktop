{ flake, config, lib, pkgs, ... }:

{
  networking.hostName = "${config.hostname}";
  networking.domain = "iksdp.local";
  networking.enableIPv6 = false;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  systemd.network.enable = true;
  
  # LAN interface
  systemd.network.networks."10-lan".enable = lib.mkDefault true;
  systemd.network.networks."10-lan".linkConfig.RequiredForOnline = "routable";
  systemd.network.networks."10-lan".matchConfig.Name = ["${config.network.interface}"];
  systemd.network.networks."10-lan".networkConfig.DHCP = "yes";
  systemd.network.networks."10-lan".networkConfig.IPv6AcceptRA = false;
  
  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.nftables.enable = false;
}
