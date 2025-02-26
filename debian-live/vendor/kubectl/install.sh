loginfo "fetchExternalPackages" "kubectl package vendor package started"

mkdir -p "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "creation of kubectl folder failed"
    exit 1
fi
curl --silent --location https://dl.k8s.io/release/v1.32.0/bin/linux/${DEBIAN_ARCH}/kubectl --output "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/kubectl
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "kubectl package download failed"
    exit 1
fi
chmod 755 "${BUILD_DIR}"/config/includes.chroot/opt/kubectl/bin/kubectl
if [ "$?" -ne 0 ]; then
    logerror "fetchExternalPackages" "chmod for kubectl failed"
    exit 1
fi
loginfo "fetchExternalPackages" "kubectl package vendor package finished"
