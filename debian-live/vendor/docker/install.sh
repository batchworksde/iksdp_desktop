loginfo "fetchExternalPackages" "docker package vendor package started"

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cp "${SCRIPT_DIR}"/docker_install_in_chroot.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "copy of docker hook failed"
    exit 1
fi

mkdir -p "${BUILD_DIR}"/config/includes.chroot/lib/live/config/
cp "${SCRIPT_DIR}"/9700-docker-group-and-storage "${BUILD_DIR}"/config/includes.chroot/lib/live/config/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of live hook failed"
  exit 1
fi

# override docker service with path to custom config
install -d "${BUILD_DIR}"/config/includes.chroot/etc/systemd/system/docker.service.d
cp "${SCRIPT_DIR}"/override.conf "${BUILD_DIR}"/config/includes.chroot/etc/systemd/system/docker.service.d/
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "copy of service override failed"
  exit 1
fi