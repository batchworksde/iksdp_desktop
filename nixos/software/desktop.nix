{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./libreoffice.nix
    ./vscode.nix
  ];

  environment.systemPackages = with pkgs; [
    chromium
    darktable
    firefox
    handbrake
    inkscape
    keepassxc
    mplayer
    nextcloud-client
    obs-studio
    rustdesk-flutter
    screen-message
    scribus
    signal-desktop
    superTux
    superTuxKart
    virt-manager
    vlc
    wireshark
    zoom-us
  ];
}
