loginfo "fetchExternalPackages" "signal package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    cp "${SCRIPT_DIR}"/signal_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "copy of signal hook failed"
        exit 1
    fi
else
    loginfo "fetchExternalPackages" "signal package vendor package skipped"
fi