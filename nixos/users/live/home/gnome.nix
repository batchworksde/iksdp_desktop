{ config, pkgs, home-manager, lib, ... }:

{
  # https://nix-community.github.io/home-manager/options.xhtml#opt-dconf.settings
  # https://github.com/nix-community/dconf2nix
  dconf.settings = let inherit (lib.hm.gvariant) mkTuple mkUint32 mkVariant; in {
    "org/gnome/software" = {
      download-updates = false;
      download-updates-notify = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 900;
    };

    "org/gnome/shell" = {
      enabled-extensions = [ "no-overview@fthx" "dash2dock-lite@icedman.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "places-menu@gnome-shell-extensions.gcampax.github.com" "drive-menu@gnome-shell-extensions.gcampax.github.com" ];
    };

    "org/gnome/shell/extensions/dash-to-panel" = {
      overview-click-to-exit = true;
      panel-positions = ''
        {"0":"TOP"}
      '';
      panel-sizes = ''
        {"0":32}
      '';
      show-favorites = false;
    };

    "org/gnome/shell/extensions/arcmenu" = {
      arcmenu-custom-hotkey = [ "Super_R" ];
      disable-user-avatar = true;
      highlight-search-result-terms = true;
      menu-button-appearance = "Text";
      pinned-app-list = [ "" "" "firefox.desktop" "" "" "org.gnome.Nautilus.desktop" "" "" "org.gnome.Terminal.desktop" "ArcMenu Settings" "ArcMenu_ArcMenuIcon" "gnome-extensions prefs arcmenu@arcmenu.com" ];
      searchbar-default-bottom-location = "Top";
    };

    "org/gnome/shell/extensions/dash2dock-lite" = {
      animate-icons-unmute = false;
      dock-location = 1;
      running-indicator-style = 2;
    };

    "org/gnome/shell/extensions/gtk4-ding" = {
      icon-size = "small";
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
    
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
