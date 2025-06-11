loginfo "fetchExternalPackages" "icaclient package download started"

curl --silent --location https://iksdplinux.s3.amazonaws.com/icaclient_25.03.0.66_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/icaclient_25.03.0.66_"${DEBIAN_ARCH}".deb
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "icaclient package download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "icaclient package download done"