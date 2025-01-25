{ flake, config, lib, pkgs, ... }:

{
  hostname = "vm-1";
  network.interface = "enp2s1";
}
