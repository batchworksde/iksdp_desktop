loginfo "fetchExternalPackages" "ulauncher package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/ulauncher_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "copy of ulauncher hook failed"
    exit 1
fi

cp "${SCRIPT_DIR}"/70-ulauncher-keybindings "${BUILD_DIR}"/config/includes.chroot/etc/dconf/db/local.d/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of key bindings failed"
  exit 1
fi

mkdir -p "${BUILD_DIR}"/config/includes.chroot/etc/xdg/autostart
cp "${SCRIPT_DIR}"/ulauncher.desktop "${BUILD_DIR}"/config/includes.chroot/etc/xdg/autostart/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of autostart failed"
  exit 1
fi

# loginfo "fetchExternalPackages" "ulauncher package vendor package started"

# loginfo "fetchExternalPackages" "ulauncher package download started"
# curl --silent https://api.github.com/repos/Ulauncher/Ulauncher/releases/latest | yq --input-format json ".assets[] | select(.name == \"ulauncher*_all.deb\") | .browser_download_url" | wget --no-verbose --output-document="${BUILD_DIR}"/config/packages.chroot/ulauncher.deb --input-file -
# if [ "$?" -ne 0 ]; then
#     logerror "fetchExternalPackages" "ulauncher package download failed"
#     exit 1
# fi
# loginfo "fetchExternalPackages" "ulauncher package download done"
