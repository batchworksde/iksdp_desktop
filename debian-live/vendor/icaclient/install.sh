WORK_DIR="$(pwd)"
BUILD_DIR="${WORK_DIR}/build"
source "${WORK_DIR}"/debian-live/build.env
DEBIAN_ARCH="$(dpkg --print-architecture)"

loginfo "${FUNCNAME[0]}" "icaclient package download starting"
curl --silent --location http://iksdp.pfadfinderzentrum.org/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb
loginfo "${FUNCNAME[0]}" "icaclient package download done"
