loginfo "fetchExternalPackages" "owncloud package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/owncloud_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "copy of owncloud hook failed"
    exit 1
fi

cp "${SCRIPT_DIR}"/9800-owncloud-autostart "${BUILD_DIR}"/config/includes.chroot/lib/live/config/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of live hook failed"
  exit 1
fi