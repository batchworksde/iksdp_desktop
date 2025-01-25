{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openssh
  ];

  # https://search.nixos.org/options?channel=24.11&from=0&size=50&sort=relevance&type=packages&query=services.openssh
  services.openssh = {
    enable = true;
    startWhenNeeded = lib.mkDefault false; # systemd.services.sshd.wantedBy does not work with it
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
    hostKeys = [
      {
        type = "ed25519";
        rounds = 256;
        path = "/nix/persistence/etc/ssh/ssh_host_ed25519_key";
      }
      {
        type = "rsa";
        bits = 4096;
        rounds = 256;
        path = "/nix/persistence/etc/ssh/ssh_host_rsa_key";
      }
    ];
    listenAddresses = [
      {
        addr = "0.0.0.0";
        port = 22;
      }
    ];
  };

  systemd.services.ssh = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];
}
