SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

WORK_DIR="$(pwd)"
BUILD_DIR="${WORK_DIR}/build"
source "${WORK_DIR}"/debian-live/build.env

cp "${SCRIPT_DIR}"/signal_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
