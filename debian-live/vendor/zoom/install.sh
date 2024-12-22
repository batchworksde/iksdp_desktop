WORK_DIR="$(pwd)"
BUILD_DIR="${WORK_DIR}/build"
source "${WORK_DIR}"/debian-live/build.env
DEBIAN_ARCH="$(dpkg --print-architecture)"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "${FUNCNAME[0]}" "icaclient package download starting"
    curl -v --silent --location https://zoom.us/client/latest/zoom_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/zoom_amd64.deb
fi