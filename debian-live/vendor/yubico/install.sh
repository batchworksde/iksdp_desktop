
loginfo "fetchExternalPackages" "yubico package vendor package started"

if [[ "$DEBIAN_ARCH" == "amd64" ]]; then
    SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    cp "${SCRIPT_DIR}"/yubico_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
else
    loginfo "fetchExternalPackages" "yubico package vendor install skipped"
fi
