loginfo "fetchExternalPackages" "drawio package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "drawio package download started"
    curl --continue-at - --silent --location url -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep browser_download_url | grep '\.deb' | cut -d '"' -f 4 | grep -i ${DEBIAN_ARCH} | wget --no-verbose --output-document="${BUILD_DIR}"/config/packages.chroot/drawio_amd64.deb -i - 

    if [ "$?" -ne 0 ]; then
      logerror "fetchExternalPackages" "drawio package download failed"
      exit 1
    fi
    loginfo "fetchExternalPackages" "drawio package download done"
else
    loginfo "fetchExternalPackages" "drawio package vendor package skipped"
fi