loginfo "fetchExternalPackages" "teams package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/teams_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/