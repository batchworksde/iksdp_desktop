loginfo "fetchExternalPackages" "webex package download started"

curl --silent --location https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb --output "${BUILD_DIR}"/config/packages.chroot/webex.deb
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "webex package download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "webex package download done"
