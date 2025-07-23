# Changelog

## v0.8.3

* added vendor packages for spotify and onyloffice (not installed by default)

## v0.8.2

* autologin now configured again

## v0.8.1

* fixed path for icaclient

## v0.8.0

* added more options to build different types of the image (e.g hdd and tar)
* fix for chromium extenions (needed if debian package webext-keepassxc-browser is not enabled)
* enabled "tap to click" for touchpads
* added vendor packages for enpass and owncloud (not installed by default)
* fix for hooks when using custom user

## v0.7.0

* removed nextcloud package from image
* removed chromium extensions for keepassxc and ublock origin and replaced them with their github version
* configure epsonscan also for old persistent users
* use https instead of http for release link

## v0.6.0

* add s3 upload to github action
* added Epson Scan software

## v0.5.0

* added gimp application
* added smbclient and nfs-common
* added chromium to gnome favorites
* updated to new version of package live-build (20250225)
* added default documentation bookmark
* added iksdp desktop wallpaper
* added boot option for updating the image (toram)

## v0.4.0

* added vendor torbrowser, drawio, kubectl
* updated ica client
* [dash-to-dock](https://extensions.gnome.org/extension/307/dash-to-dock/) instead of [Dash2Dock Animated](https://extensions.gnome.org/extension/4994/dash2dock-lite/) because of [issue #80](https://github.com/batchworksde/iksdp_desktop/issues/80)
* generic hostname `desktop`

## v0.3.0

* default configuration for Gnome and Gnome shell extensions for easier accessibility
* added mode indicator
* added possibility to boot luks encrypted persistent volumes
* [ZRAM based](https://wiki.debian.org/ZRam) swap added
* `/tmp` using tmpfs managed with systemd
* `50%` for ZRAM swap and /tmp tmpfs
* default settings for firefox and chromium

## v0.2.0

* [Rustdesk Client](https://rustdesk.com/docs/en/client/)
* always download the latest Zoom client version
* [OBS Studio](https://obsproject.com/)

## v0.1.0

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
