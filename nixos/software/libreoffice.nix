{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hunspell
    libreoffice
    hyphenDicts.de_DE
    hyphenDicts.de-de
  ];
}

