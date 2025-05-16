loginfo "fetchExternalPackages" "owncloud package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/owncloud_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "copy of owncloud hook failed"
    exit 1
fi