{ config, pkgs, home-manager, ... }:

{
  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ll = "ls -lAh";
        cp = "cp -iv";
        mv = "mv -iv";
        rm = "rm -iv";
        df = "df -h";
      };
    };
  };
}
