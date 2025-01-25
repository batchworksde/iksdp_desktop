{ flake, config, lib, pkgs, ... }:

{
  hostname = "linux-art";
  network.interface = "enp5s0";

  imports = [ 
    ./software.nix
  ];
}
