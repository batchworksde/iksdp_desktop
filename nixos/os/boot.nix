{ config, lib, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" "aesni_intel" "cryptd" "nvme" "ext4" ];
      kernelModules = [ "dm-snapshot" ];
      systemd.enable = lib.mkIf (config.persistence.type == "preservation") true;
    };
    extraModulePackages = with config.boot.kernelPackages; [ ];
    kernelPackages = pkgs.linuxPackages;
    blacklistedKernelModules = [ ];
    loader = {
      grub = {
        enable = lib.mkIf (config.bootloader.type == "grub") true;
        efiSupport = true;
        configurationLimit = 16;
        memtest86.enable = true;
        device = "nodev";
        efiInstallAsRemovable = true;
        splashImage= pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/batchworksde/iksdp_desktop/refs/heads/main/debian-live/config/bootloaders/grub-pc/splash.png";
          sha256 = "16bj097fnximzfs871jiqa2a9k9i2nimxlfra9qk2ij9rv82qsw2";
        };
        extraConfig = ''
          #set superusers="" # disable the edit mode https://www.gnu.org/software/grub/manual/grub/html_node/Authentication-and-authorisation.html
        '';
      };
      systemd-boot = {
        enable = lib.mkIf (config.bootloader.type == "systemd") true;
        consoleMode = "auto";
        editor = false;
        configurationLimit = 16;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = false;
    };
    plymouth = {
      enable = true;
      theme = "rings";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "rings" ];
        })
      ];
    };
    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
