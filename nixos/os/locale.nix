{ config, lib, pkgs, ... }:

{
  i18n = {
    # https://sourceware.org/git/?p=glibc.git;a=blob;f=localedata/SUPPORTED
    defaultLocale = "en_US.UTF-8/UTF-8";
    supportedLocales = [
      config.i18n.defaultLocale
      "sw_KE/UTF-8"
      "so_KE.UTF-8/UTF-8"
      "om_KE.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };
  services.xserver.xkb.layout = "us,ke,de";
  console.useXkbConfig = true;
}
