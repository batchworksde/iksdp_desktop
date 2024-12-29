echo ${FUNCNAME}
if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "${FUNCNAME[0]}" "icaclient package download starting"
    curl --silent --location https://zoom.us/client/latest/zoom_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/zoom_amd64.deb
fi