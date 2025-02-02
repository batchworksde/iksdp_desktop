# IKSDP desktop

A Debian Linux based Desktop configuration for the International Kenya Scout Development Project [(IKSDP)](https://iksdpnyandiwa.net/).

- [IKSDP desktop](#iksdp-desktop)
  - [Downloads](#downloads)
  - [Configuration](#configuration)
    - [Debian Live configuration](#debian-live-configuration)
    - [Github runner configuration](#github-runner-configuration)
    - [Live image configuration](#live-image-configuration)
  - [Changelog](#changelog)
  - [Links](#links)

## Downloads

We create versioned [releases](https://github.com/batchworksde/iksdp_desktop/releases) for the IKSDP Desktop. Every release contains a link to the related ISO image.

## Configuration

- boot a [NixOS minimal image](https://channels.nixos.org/nixos-24.11/latest-nixos-minimal-aarch64-linux.iso) on a computer or VM
- become root
- start a nix shell with the git package enabled
- partition the attached NVMe disk
- download the Citrix ICA client(because of the EULA download limitation)
- start the NixOS installation
- use `pc-1` or `vm-1` for `#hostname` in the git url `iksdp_desktop.git?ref=nixos&dir=nixos#hostname`
- enter a new root password when prompted

```shell=bash
sudo -i
nix-shell -p git
nix --experimental-features "nix-command flakes" run 'github:nix-community/disko/v1.11.0#disko' -- --mode disko --flake 'git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos#hostname'
nix-prefetch-url http://iksdp.pfadfinderzentrum.org/linuxx64-24.5.0.76.tar.gz
nixos-install --flake 'git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos#hostname'

sudo nixos-rebuild switch --flake 'git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos'

nix --extra-experimental-features 'nix-command flakes' eval 'git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos#nixosConfigurations.vm-1.config.boot.initrd.systemd.enable'

nix --extra-experimental-features 'nix-command flakes' eval 'git+https://github.com/batchworksde/iksdp_desktop.git?ref=nixos&dir=nixos#nixosConfigurations.vm-1.config.preservation' --json | jq .
```

### Debian Live configuration

| Parameter   | Value       | Description     |
| :---        | :----:      | :---            |
| `DEBIAN_VERSION` | bookworm | The [Debian release](https://www.debian.org/releases/index.en.html) that should be used for the live image |
| `DEBIAN_MIRROR` | http://deb.debian.org/debian | Debian mirror [Url](http://deb.debian.org/) selected from the [mirror list](https://www.debian.org/mirror/list) |
| `DEBIAN_SEC_MIRROR` | http://deb.debian.org/debian-security | Debian mirror [Url](http://deb.debian.org/) for the security packages |
| `DEBIAN_SQUASHFS_COMPRESSION_TYPE` | zstd | [compression algorithm](https://manpages.debian.org/bookworm/live-build/lb_config.1.en.html#chroot~3) that should be used for the root filesystem image |
| `DEBIAN_SQUASHFS_COMPRESSION_LEVEL` | 15 | [compression level](https://manpages.debian.org/bookworm/live-build/lb_config.1.en.html#chroot~2) that should be used for the root filesystem image |
| `DEBIAN_LOCALES` | en_US.UTF-8 | comma separated list of [locales](https://wiki.debian.org/Locale) that should be available in the live image |
| `DEBIAN_KEYBOARD_LAYOUTS` | us | comma separated list of [keyboard leyouts](https://www.debian.org/doc/manuals/debian-reference/ch08.en.html#_the_keyboard_input) that should be available in the live image |
| `DEBIAN_TIMEZONE` | Africa/Nairobi | [time zone](https://wiki.debian.org/TimeZoneChanges) that should be configured in the live image |
| `DEBIAN_SUDO_DISABLE` | false | Disables [sudo and policykit](https://manpages.debian.org/bookworm/open-infrastructure-system-config/live-config.7.en.html#live~23), the user cannot gain root privileges on the live system |
| `DEBIAN_USER_PERSISTENCE` | true | The user home should be [persisted](https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-run-time-behaviours.en.html#556) on some attached (USB) storage |
| `DEBIAN_ZOOM_VERSION` | 6.2.6.2503 | Version of the Debian package for the [Zoom client](https://zoom.us/download?os=linux) |

### Github runner configuration

| Parameter   | Value       | Description     |
| :---        | :----:      | :---            |
| `DEBIAN_LIVE_BUILD_VERSION` | 20230502 | version of the [live-build](https://packages.debian.org/bookworm/live-build) package that should be installed on the Github runner to build the live image |
| `RUNNER_CLEANUP` | false | remove [not required folders](https://github.com/actions/runner-images/issues/10386) from the runner to free up some space for the image build process |
| `RUNNER_SYSINFO` | false | collect some system information from the runner |
| `RUNNER_PACKAGES` | () | additional [Ubuntu 24.04 packages](https://packages.ubuntu.com/) that should be installed on the runner |

### Live image configuration

| Parameter   | Value       | Description     |
| :---        | :----:      | :---            |
| `RELEASE_VERSION` | 0.2.0 | version number for the generated live image |

## Changelog

The [changelog](CHANGELOG.md)

## Links

- [DebianLive UsbPersistence](https://wiki.debian.org/DebianLive/LiveUsbPersistence)
- [Debian Live Manual](https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html)
- [Debian live-config manpage](https://manpages.debian.org/bookworm/live-config-doc/live-config.7.en.html)
- [Debian live-build manpage](https://manpages.debian.org/bookworm/live-build/live-build.7.en.html)
