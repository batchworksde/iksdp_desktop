{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    linux-firmware
    broadcom-bt-firmware
    rtl8192su-firmware
  ];
}
