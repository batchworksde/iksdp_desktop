# https://support.epson.net/linux/en/epsonscan2.php
# choose the "64bit(x86_64) Deb" download link 
# copy the id from your browser download history into the id field (packages.vendor.app.epsonscan.id) in the package.yaml
# copy the version from your browser download history into the version field (packages.vendor.app.epsonscan.version) in the package.yaml
# example: https://download3.ebz.epson.net/dsc/f/03/00/16/14/38/7b1780ace96e2c6033bbb667c7f3ed281e4e9f38/epsonscan2-bundle-6.7.70.0.x86_64.deb.tar.gz
# id = 'f/03/00/16/14/38/7b1780ace96e2c6033bbb667c7f3ed281e4e9f38'
# version = 6.7.70.0

function fetchEpsonScannerPackage {
  loginfo "${FUNCNAME[0]}" "package download started"

  local targetfolder version id url
  targetfolder="${BUILD_DIR}/config/packages.chroot"
  version=$(yq -r '.packages.vendor.app.epsonscan.version' "${WORK_DIR}"/debian-live/package.yaml)
  id=$(yq -r '.packages.vendor.app.epsonscan.id' "${WORK_DIR}"/debian-live/package.yaml)
  url="https://download3.ebz.epson.net/dsc/${id}/epsonscan2-bundle-${version}.x86_64.deb.tar.gz"

  curl --silent --location "${url}" --output "${BUILD_DIR}"/config/packages.chroot/epsonscan2-bundle-"${version}".x86_64.deb.tar.gz
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "${url} download failed"
    exit 1
  fi
  
  tar --extract --gzip --no-same-owner --no-same-permissions --wildcards --directory="${BUILD_DIR}"/config/packages.chroot/ --strip-components=2 --file="${BUILD_DIR}"/config/packages.chroot/epsonscan2-bundle-"${version}".x86_64.deb.tar.gz epsonscan2-bundle-"${version}".x86_64.deb/core/epsonscan2*.deb
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "core/epsonscan2_amd64.deb extract failed"
    exit 1
  fi

  tar --extract --gzip --no-same-owner --no-same-permissions --wildcards --directory="${BUILD_DIR}"/config/packages.chroot/ --strip-components=2 --file="${BUILD_DIR}"/config/packages.chroot/epsonscan2-bundle-"${version}".x86_64.deb.tar.gz epsonscan2-bundle-"${version}".x86_64.deb/plugins/epsonscan2*.deb
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "plugins/epsonscan2_amd64.deb extract failed"
    exit 1
  fi

  rm "${BUILD_DIR}"/config/packages.chroot/epsonscan2-bundle-${version}.x86_64.deb.tar.gz
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "${BUILD_DIR}/config/packages.chroot/epsonscan2-bundle-${version}.x86_64.deb.tar.gz delete failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "package download done"
}

fetchEpsonScannerPackage