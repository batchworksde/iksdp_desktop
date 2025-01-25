{ config, lib, pkgs, ... }:

{
  # https://search.nixos.org/packages
  environment.systemPackages = with pkgs; [
    btop
    cryptsetup
    curl
    dnsutils
    docker
    dosfstools
    ethtool
    flatpak
    fusePackages.fuse_2
    fwupd
    fzf
    git
    htop
    iw
    jq
    kopia
    less
    libvirt
    links2
    lm_sensors
    mc
    ntfs3g
    p7zip
    pigz
    podman
    python3Full
    restic
    ripgrep
    rustup
    screen
    strace
    sysstat
    tcpdump
    tmux
    unzip
    vim
    wget
    whois
    wpa_supplicant
    xz
    yq-go
    zellij
    zip
  ];

  imports = [ 
    ./alsa.nix
    ./golang.nix
    ./firmware.nix
    ./nix-daemon.nix
    ./gnome.nix
    ./openssh.nix
    ./thermald.nix
  ];

  programs.dconf.enable = true;
}
