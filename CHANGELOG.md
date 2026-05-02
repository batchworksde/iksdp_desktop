# Changelog

## 0.11.2

* Package versions updated
* [copy fail](https://security-tracker.debian.org/tracker/CVE-2026-31431) patches included

## 0.11.1

* [mdq](https://github.com/yshavit/mdq/) added to generate the `RELEASE_VERSION` from the [change log](CHANGELOG.md)
* workflows updated to publish the release after the pull request has been merged
* Package versions updated

## 0.11.0

* Package versions updated
* use /etc/apt/keyrings for all vendor packages
* updated to Debian 13 packages for owncloud package (start owncloud automatically at logon if in persistent mode and config file already exists)
* updated repository signing key for Spotify
* temporary (unsecure) fix for repositories still using SHA1 signing keys
* new vendor packages (albert, bitwarden, docker, ghostty and ulauncher)
* new update script for updating installations using the tar method

## 0.10.2

* Package versions updated

## 0.10.1

* Package versions updated

## 0.10.0

* added MD5 hash of ISO image to release files
* indicator for update mode in the top bar
* script for updating the image

## 0.9.3

* Package versions updated
* use Debian package for the Keepassxc browser extension

## 0.9.2

* Package versions updated

## 0.9.1

* Package versions updated

## 0.9.0

* Debian updated from Bookworm to Trixie
* Scratch disabled in package list because it is not supported in Trixie
* added vendor packages for spotify and onyloffice (not installed by default)
* disabled PackageKit (prevents showing Debian packages in Gnome-Software)
* added packages gnome-shell-extensions and gnome-shell-extension-prefs (not installed by default with Trixie)
* changed gnome shell extension persistence-indicator@batchworks.de to be compatible with version 48
* added option to remove debian packages via package.yaml (e.g. gnome-tour which gets installed as a recommended package)

## 0.8.2

* autologin now configured again

## 0.8.1

* fixed path for icaclient

## 0.8.0

* added more options to build different types of the image (e.g hdd and tar)
* fix for chromium extenions (needed if debian package webext-keepassxc-browser is not enabled)
* enabled "tap to click" for touchpads
* added vendor packages for enpass and owncloud (not installed by default)
* fix for hooks when using custom user

## 0.7.0

* removed nextcloud package from image
* removed chromium extensions for keepassxc and ublock origin and replaced them with their github version
* configure epsonscan also for old persistent users
* use https instead of http for release link

## 0.6.0

* add s3 upload to github action
* added Epson Scan software

## 0.5.0

* added gimp application
* added smbclient and nfs-common
* added chromium to gnome favorites
* updated to new version of package live-build (20250225)
* added default documentation bookmark
* added iksdp desktop wallpaper
* added boot option for updating the image (toram)

## 0.4.0

* added vendor torbrowser, drawio, kubectl
* updated ica client
* [dash-to-dock](https://extensions.gnome.org/extension/307/dash-to-dock/) instead of [Dash2Dock Animated](https://extensions.gnome.org/extension/4994/dash2dock-lite/) because of [issue #80](https://github.com/batchworksde/iksdp_desktop/issues/80)
* generic hostname `desktop`

## 0.3.0

* default configuration for Gnome and Gnome shell extensions for easier accessibility
* added mode indicator
* added possibility to boot luks encrypted persistent volumes
* [ZRAM based](https://wiki.debian.org/ZRam) swap added
* `/tmp` using tmpfs managed with systemd
* `50%` for ZRAM swap and /tmp tmpfs
* default settings for firefox and chromium

## 0.2.0

* [Rustdesk Client](https://rustdesk.com/docs/en/client/)
* always download the latest Zoom client version
* [OBS Studio](https://obsproject.com/)

## 0.1.0

* Debian 12 (Bookworm)
* GNOME Desktop plus Boxes, Builder and Connections
* Libreoffice, Chromium, Firefox
* VLC, mplayer
* Inkscape, Scribus, Darktable, Handbrake
* Apostrophe, Keepassxc
* Zoom client
* Supertux, Torcs
* Golang, Python3, Rust, Scratch
* curl, wget, links2, jq
* podman
* vim, mc, screen, tmux, htop
* Flatpak support with [Flathub](https://flathub.org/) repo added
* Binary firmware for various drivers in the Linux kernel
