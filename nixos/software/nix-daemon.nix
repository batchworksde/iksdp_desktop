{ config, lib, pkgs, ... }:

{
  systemd.services = {
    nix-daemon = {
      environment = {
        TMPDIR = "/run/nix-daemon";
      };

      serviceConfig = {
        RuntimeDirectory = "nix-daemon";
      };
    };
  };
}