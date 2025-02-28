loginfo "fetchExternalPackages" "zoom package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "zoom package download started"
    curl --silent --location https://zoom.us/client/latest/zoom_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/zoom_amd64.deb
    if [ "$?" -ne 0 ]; then
      logerror "fetchExternalPackages" "zoom package download failed"
      exit 1
    fi
    loginfo "fetchExternalPackages" "zoom package download done"
else
    loginfo "fetchExternalPackages" "zoom package vendor package skipped"
fi