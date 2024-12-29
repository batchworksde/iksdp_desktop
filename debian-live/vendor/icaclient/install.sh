loginfo "fetchExternalPackages" "icaclient package download started"
curl --silent --location http://iksdp.pfadfinderzentrum.org/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "icaclient package download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "icaclient package download done"