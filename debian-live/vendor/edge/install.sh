SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"


if [[ "$DEBIAN_ARCH" == "amd64" ]]; then
    # to check
    #SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    # cp "${SCRIPT_DIR}"/edge_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/

    # other way - not fine but working.. 
    loginfo "fetchExternalPackages" "egde package download started"
    curl -C - --silent --location https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_131.0.2903.99-1_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/microsoft-edge-stable_131.0.2903.99-1_amd64.deb
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "egde package download failed"
        exit 1
    fi

    loginfo "fetchExternalPackages" "egde package download done"
fi
