loginfo "fetchExternalPackages" "albert package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/albert_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "copy of albert hook failed"
    exit 1
fi

cp "${SCRIPT_DIR}"/70-albert-keybindings "${BUILD_DIR}"/config/includes.chroot/etc/dconf/db/local.d/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of key bindings failed"
  exit 1
fi

mkdir -p "${BUILD_DIR}"/config/includes.chroot/etc/skel/.config/albert/
cp "${SCRIPT_DIR}"/config "${BUILD_DIR}"/config/includes.chroot/etc/skel/.config/albert/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of default config failed"
  exit 1
fi

mkdir -p "${BUILD_DIR}"/config/includes.chroot/etc/skel/.local/share/albert/
cp "${SCRIPT_DIR}"/state "${BUILD_DIR}"/config/includes.chroot/etc/skel/.local/share/albert/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of state file failed"
  exit 1
fi

mkdir -p "${BUILD_DIR}"/config/includes.chroot/etc/xdg/autostart
cp "${SCRIPT_DIR}"/albert.desktop "${BUILD_DIR}"/config/includes.chroot/etc/xdg/autostart/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of autostart failed"
  exit 1
fi

cp "${SCRIPT_DIR}"/9800-albert-update-user-home "${BUILD_DIR}"/config/includes.chroot/lib/live/config/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of live hook failed"
  exit 1
fi