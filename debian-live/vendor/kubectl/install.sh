loginfo "fetchExternalPackages" "kubectl package vendor package started"

mkdir -p "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/
curl --continue-at - --silent --location https://dl.k8s.io/release/v1.32.0/bin/linux/${DEBIAN_ARCH}/kubectl --output "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/kubectl
chmod 755 "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/kubectl
loginfo "fetchExternalPackages" "kubectl package vendor package finished"
