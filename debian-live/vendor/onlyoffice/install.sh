loginfo "fetchExternalPackages" "onlyoffice package download started"

curl --silent https://api.github.com/repos/ONLYOFFICE/DesktopEditors/releases/latest | yq --input-format json ".assets[] | select(.name == \"onlyoffice-desktopeditors_${DEBIAN_ARCH}.deb\") | .browser_download_url" | wget --no-verbose --output-document="${BUILD_DIR}"/config/packages.chroot/onlyoffice-desktopeditors_${DEBIAN_ARCH}.deb --input-file -
if [ "$?" -ne 0 ]; then
  logerror "fetchExternalPackages" "onlyoffice package download failed"
  exit 1
fi
loginfo "fetchExternalPackages" "onlyoffice package download done"
