SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

cp "${SCRIPT_DIR}"/vscode_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/