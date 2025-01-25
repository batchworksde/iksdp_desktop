{ config, lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          banner = ''
            This is the IKSDP Linux Desktop
            The live user will autologin in 5s
          '';
          autoLogin.delay = 5;
        };
      };
      desktopManager.gnome = {
        enable = true;
        # example for a Gnome config not managed by the home-manager
        # extraGSettingsOverridePackages = [ pkgs.mutter ];
        # extraGSettingsOverrides = ''
        #   [org.gnome.mutter]
        #   experimental-features=['scale-monitor-framebuffer']
        # '';
      };
    };
    displayManager = {
      enable = true;
      defaultSession = "gnome";
      autoLogin = {
        enable = true;
        user = "live";
      };
    };
    gnome.localsearch.enable = true;
    udev.packages = [ pkgs.gnome-settings-daemon ];
    
  };

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    apostrophe
    cheese
    gnome-bluetooth
    gnome-boxes
    gnome-builder
    gnome-connections
    gnome-firmware
    gnome-maps
    gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.arcmenu
    gnomeExtensions.dash-to-panel
    gnomeExtensions.dash2dock-lite
    gnomeExtensions.gtk4-desktop-icons-ng-ding
    gnomeExtensions.no-overview
    gnomeExtensions.open-bar
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-initial-setup
  ];

  imports = [ 
    ./desktop.nix
  ];
}
