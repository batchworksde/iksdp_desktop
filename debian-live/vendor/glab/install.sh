loginfo "fetchExternalPackages" "gitlab glab cli client download started"

curl --silent --location https://gitlab.com/gitlab-org/cli/-/releases/v1.109.0/downloads/glab_1.109.0_linux_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/glab_1.109.0_linux_"${DEBIAN_ARCH}".deb

if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "gitlab glab cli client download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "gitlab glab cli client download done"
