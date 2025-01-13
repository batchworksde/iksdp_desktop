loginfo "fetchExternalPackages" "icaclient package download started"

curl --continue-at - --silent --location http://iksdp.pfadfinderzentrum.org/icaclient_24.11.0.85_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/icaclient_24.11.0.85_"${DEBIAN_ARCH}".deb
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "icaclient package download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "icaclient package download done"