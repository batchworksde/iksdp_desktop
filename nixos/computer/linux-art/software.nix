{ config, lib, pkgs, ... }:

{
  # https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    drawio
    citrix_workspace
    mermaid-cli
    mermaid-filter
    pandoc
    teams-for-linux
    texliveFull
    yubico-piv-tool
  ];
}
