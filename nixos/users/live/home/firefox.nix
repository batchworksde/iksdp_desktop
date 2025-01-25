{ config, pkgs, home-manager, ... }:

{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "de"
      ];
      # https://mozilla.github.io/policy-templates/
      policies = {
        DefaultDownloadDirectory = "\${home}/Downloads";
        ManagedBookmarks = [
          {
            toplevel_name = "managed bookmarks";
          }
          {
            url = "https://en.wikipedia.org/wiki/Main_Page";
            name = "Wikipedia";
          }
          {
            name = "IKSDP links";
            children = [
              {
                url = "https://iksdpnyandiwa.net/en/";
                name = "Nyandiwa International Scout Centre";
              }
              {
                url = "https://github.com/batchworksde/iksdp_desktop";
                name = "IKSDP Desktop Git Repo";
              }
            ];
          }
        ];
        DisableFirefoxStudies = true;
        DisableAppUpdate = true;
        DisablePocket = true;
        DisableTelemetry = true;
        Extensions= {
          Install = [
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
          ];
        };
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            updates_disabled = false;
          };
        };
        FirefoxHome = {
          Search = true;
          TopSites = true;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = false;
        };
        FirefoxSuggest = {
          WebSuggestions = false;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = false;
        };
        HardwareAcceleration = true;
        RequestedLocales = "en-US,de";
        SSLVersionMin = "tls1.2";
        TranslateEnabled = true;
        UserMessaging = {
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          UrlbarInterventions = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          FirefoxLabs = false;
          Locked = false;
        };
      };
    };
  };
}
