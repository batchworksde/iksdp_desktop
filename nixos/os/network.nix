{ flake, config, lib, pkgs, ... }:

{
  networking.hostName = "${config.hostname}";
  networking.domain = "iksdp.local";
  networking.enableIPv6 = false;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;
  
  # LAN interface
  systemd.network = {
    enable = true;
    networks."10-lan" = {
      enable = lib.mkDefault true;
      matchConfig.Name = ["${config.network.interface}"];
      networkConfig.DHCP = "yes";
      networkConfig.IPv6AcceptRA = false;
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # (m)DNS
  services.resolved = {
    enable = true;
    fallbackDns = [
      "9.9.9.9" #https://www.quad9.net/service/service-addresses-and-features
      "8.8.8.8" #https://developers.google.com/speed/public-dns
      "1.1.1.1" #https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/
      "2620:fe::fe" #https://www.quad9.net/service/service-addresses-and-features
    ];
    dnssec = "allow-downgrade";
    dnsovertls = "opportunistic";
  };
  

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.nftables.enable = false;
}
