loginfo "fetchExternalPackages" "drawio package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "drawio package download started"
    curl --continue-at - --silent https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | yq --input-format json ".assets[] | select(.name == \"drawio-amd64-*.deb\") | .browser_download_url" | wget --no-verbose --output-document="${BUILD_DIR}"/config/packages.chroot/drawio_amd64.deb --input-file -

    if [ "$?" -ne 0 ]; then
      logerror "fetchExternalPackages" "drawio package download failed"
      exit 1
    fi
    loginfo "fetchExternalPackages" "drawio package download done"
else
    loginfo "fetchExternalPackages" "drawio package vendor package skipped"
fi