#!/usr/bin/env bash
# shellcheck disable=SC2181,SC2016,SC2164
set +e
set -u
set -o pipefail

declare USE_CASE WORK_DIR BUILD_DIR IMAGE_TIMESTAMP GITHUB_API_VERSION GITHUB_API_MIMETYPE

DEBIAN_ARCH="$(dpkg --print-architecture)"
USE_CASE="${1-localBuild}"
WORK_DIR="$(pwd)"
BUILD_DIR="${WORK_DIR}/build"
GITHUB_API_VERSION="X-GitHub-Api-Version: 2022-11-28"
GITHUB_API_MIMETYPE="Accept: application/vnd.github+json"

export USE_CASE WORK_DIR BUILD_DIR GITHUB_API_VERSION GITHUB_API_MIMETYPE

function logjson {
  printf "{\"@timestamp\":\"%s\",\"ecs.version\":\"1.6.0\",\"log.logger\":\"%s\",\"log.origin.function\":\"%s\",\"log.level\":\"%s\",\"message\":\"%s\"}\n" "$(date +%Y-%m-%dT%H:%M:%S+%Z)" "$3" "$4" "$2" "$5" >>/dev/"$1"
}

function loginfo {
  logjson "stdout" "info" "$0" "$1" "$2"
}

function logdebug {
  logjson "stdout" "debug" "$0" "$1" "$2"
}

function logerror {
  logjson "stderr" "error" "$0" "$1" "$2"
}

function checkRootPw {
  # check if ROOTPW is set
  if [ -z "${ROOTPW+x}" ]; then
    logerror "${FUNCNAME[0]}" "ROOTPW var is not set"
    exit 1
  fi

  export ROOTPW
}

function importEnvVars {
  loginfo "${FUNCNAME[0]}" "Loading 'build.env' environment variables"
  set -a # automatically export all variables
  source "${WORK_DIR}"/debian-live/build.env
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Environment variables import failed"
    exit 1
  fi
}

function createBuildDir {
  loginfo "${FUNCNAME[0]}" "Creating build directory"

  createFolder "${BUILD_DIR}"
}

function cleanupConfig {
  loginfo "${FUNCNAME[0]}" "Clean up build directory"

  cd "${BUILD_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${BUILD_DIR} failed"
    exit 1
  fi

  sudo lb clean
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "live-build cleanup failed"
    exit 1
  fi

  if [ -d "${BUILD_DIR}"/config/ ]; then
    rm -r $(ls -d config/* | grep -v '^config/packages.chroot$')
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "config dir removal failed"
      exit 1
    fi
  fi

  cd "${WORK_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${WORK_DIR} failed"
    exit 1
  fi
}

function configImage {
  loginfo "${FUNCNAME[0]}" "Configuring the Debian image"

  local liveConfigOptions=""
  if [ "${DEBIAN_SUDO_DISABLE}" == "true" ]; then
    liveConfigOptions+=" noroot"
  fi

  if [ "${DEBIAN_USER_PERSISTENCE}" == "true" ]; then
    liveConfigOptions+=" persistence persistence-encryption=luks,none"
  else
    liveConfigOptions+=" nopersistence"
  fi

  if [ "${DEBIAN_MEDIUM_NOEJECT}" == "true" ]; then
    liveConfigOptions+=" noeject"
  fi

  if [ "${DEBIAN_BOOT_SPLASH}" == "true" ]; then
    liveConfigOptions+=" quiet splash"
  fi

  if [ "${DEBIAN_AUTOLOGIN}" == "false" ]; then
    liveConfigOptions+=" noautologin"
  fi

  if [ ${DEBIAN_USER_FULLNAME+x} ]; then
    mkdir -p "${BUILD_DIR}"/config/includes.chroot/etc/live/config.conf.d/
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "live-config dir creation failed"
      exit 1
    fi
    echo "LIVE_USER_FULLNAME=\"${DEBIAN_USER_FULLNAME}\"" > "${BUILD_DIR}"/config/includes.chroot/etc/live/config.conf.d/user-fullname.conf
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "setting user fullname in live-config failed"
      exit 1
    fi
  fi

  cd "${BUILD_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${BUILD_DIR} failed"
    exit 1
  fi

  lb config \
    --distribution "${DEBIAN_VERSION}" \
    --mirror-bootstrap "${DEBIAN_MIRROR}" \
    --mirror-chroot "${DEBIAN_MIRROR}" \
    --mirror-binary "${DEBIAN_MIRROR}" \
    --mirror-chroot-security "${DEBIAN_SEC_MIRROR}" \
    --mirror-binary-security "${DEBIAN_SEC_MIRROR}" \
    --backports ${DEBIAN_BACKPORTS} \
    --updates true \
    --security true \
    --architectures "${DEBIAN_ARCH}" \
    --apt-recommends true \
    --apt-indices false \
    --cache true \
    --cache-packages true \
    --checksums "sha256" \
    --chroot-squashfs-compression-level "${DEBIAN_SQUASHFS_COMPRESSION_LEVEL}" \
    --chroot-squashfs-compression-type "${DEBIAN_SQUASHFS_COMPRESSION_TYPE}" \
    --binary-image "${DEBIAN_BINARY_IMAGE}" \
    --bootloaders "${DEBIAN_BOOTLOADERS}" \
    --binary-filesystem "${DEBIAN_BINARY_FILESYSTEM}" \
    --compression "${DEBIAN_TAR_COMPRESSION_TYPE}" \
    --archive-areas "main non-free-firmware" \
    --bootappend-live "boot=live config hostname="${DEBIAN_HOSTNAME}" locales=${DEBIAN_LOCALES} keyboard-layouts=${DEBIAN_KEYBOARD_LAYOUTS} timezone=${DEBIAN_TIMEZONE} username=${DEBIAN_USERNAME} ${liveConfigOptions}" \
    --image-name debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian image configuration failed"
    exit 1
  fi

  cd "${WORK_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${WORK_DIR} failed"
    exit 1
  fi
}

function configPackages {
  loginfo "${FUNCNAME[0]}" "Configure Debian package list"
  cp "${WORK_DIR}"/debian-live/config/package-lists/hooks.list.chroot "${BUILD_DIR}"/config/package-lists/
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian package list config for hooks failed"
    exit 1
  fi

  yq '.packages.debian | select(.enable) | .app[] | select(.enable) | .name' "${WORK_DIR}"/debian-live/package.yaml >"${BUILD_DIR}"/config/package-lists/debian.list.chroot
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian package list config failed"
    exit 1
  fi
}

function configHooks {
  loginfo "${FUNCNAME[0]}" "Configure Debian Live build hooks"
  local DEBIAN_FLATPAK_PACKAGES GNOME_SHELL_EXTENSIONS

  cp "${WORK_DIR}"/debian-live/config/hooks/normal/*.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live hook config failed"
    exit 1
  fi

  DEBIAN_FLATPAK_PACKAGES="$(yq '.packages.flatpak | select(.enable) | .flathub | select(.enable) | .app | filter(.enable) | map (.name) | join (" ")' "${WORK_DIR}"/debian-live/package.yaml)"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" ".packages.flatpak parsing failed"
    exit 1
  fi

  envsubst '${DEBIAN_FLATPAK_PACKAGES}' <"${WORK_DIR}"/debian-live/config/hooks/normal/9000-install-flathub-flatpak-packages-system.hook.chroot.template >"${BUILD_DIR}"/config/hooks/normal/9000-install-flathub-flatpak-packages-system.hook.chroot
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live envsubst for flatpak failed"
    exit 1
  fi

  GNOME_SHELL_EXTENSIONS="$(yq '.packages.gnome-shell | select(.enable) | .extension | filter(.enable) | map (.id) | join (" ")' "${WORK_DIR}"/debian-live/package.yaml)"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" ".packages.gnome-shell parsing failed"
    exit 1
  fi

  envsubst '${GNOME_SHELL_EXTENSIONS}' <"${WORK_DIR}"/debian-live/config/hooks/normal/9100-install-gnome-shell-extensions.hook.chroot.template >"${BUILD_DIR}"/config/hooks/normal/9100-install-gnome-shell-extensions.hook.chroot
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live envsubst for gnome shell extensions failed"
    exit 1
  fi

  CHROMIUM_EXTENSIONS="$(yq '.packages.chromium | select(.enable) | .extension | filter(.enable) | map (.org + "/" + .repo) | join (" ")' "${WORK_DIR}"/debian-live/package.yaml)"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" ".packages.chromium parsing failed"
    exit 1
  fi

  envsubst '${CHROMIUM_EXTENSIONS}' <"${WORK_DIR}"/debian-live/config/hooks/normal/9500-chromium-extensions.hook.chroot.template >"${BUILD_DIR}"/config/hooks/normal/9500-chromium-extensions.hook.chroot
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live envsubst for chromium extensions failed"
    exit 1
  fi
}

function setRootPw {
  loginfo "${FUNCNAME[0]}" "setting root password"
  envsubst '${ROOTPW}' <"${WORK_DIR}"/debian-live/config/hooks/normal/9300-setrootpw.hook.chroot.template >"${BUILD_DIR}"/config/hooks/normal/9300-setrootpw.hook.chroot
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "creation of rootpw hook failed"
    exit 1
  fi
}

function configIncludes {
  loginfo "${FUNCNAME[0]}" "Configure Debian Live includes.chroot"
  cp -r "${WORK_DIR}"/debian-live/config/includes.chroot "${BUILD_DIR}"/config/
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live includes.chroot failed"
    exit 1
  fi
}

function fetchExternalPackages {
  loginfo "${FUNCNAME[0]}" "Fetch external Debian packages"
  local vendorpackagelist githubpackagelist

  vendorpackagelist=($(yq -r '.packages.vendor | select(.enable) | .app[] | select(.enable) | .name' "${WORK_DIR}"/debian-live/package.yaml))
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" ".packages.vendor parsing failed"
    exit 1
  fi

  for package in "${vendorpackagelist[@]}"; do
        SCRIPT_PATH="${WORK_DIR}"/debian-live/vendor/"${package}/install.sh"
        if [ -f "${SCRIPT_PATH}" ]; then
          source "${SCRIPT_PATH}"
          if [ "$?" -ne 0 ]; then
            logerror "${FUNCNAME[0]}" "Vendor package script ${SCRIPT_PATH} failed"
            exit 1
          fi
        else
          logerror "${FUNCNAME[0]}" "No ${package} external package definition found"
          exit 1
        fi
  done

  readarray githubpackagelist < <(yq --output-format json --indent 0 '.packages.github | select(.enable) | .app | filter(.enable) | .[]' "${WORK_DIR}"/debian-live/package.yaml)
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" ".packages.github parsing failed"
    exit 1
  fi

  for package in "${githubpackagelist[@]}"; do
    downloadGithubRelease "${package}"
  done
}

function downloadGithubRelease {
  if [ -n "${1}" ]; then
    local repo org suffix releases url version targetfolder dlversion dlname dlarch

    targetfolder="${BUILD_DIR}/config/packages.chroot"

    repo="$(echo "${1}" | yq --input-format json '.repo')"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "Unable to parse .packages.github.app[].repo"
      exit 1
    fi

    org="$(echo "${1}" | yq --input-format json '.org')"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "Unable to parse .packages.github.app[].org"
      exit 1
    fi

    suffix="$(echo "${1}" | yq --input-format json '.artifactsuffix')"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "Unable to parse .packages.github.app[].artifactsuffix"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "${repo} package download started"

    releases="$(curl --silent --header "${GITHUB_API_MIMETYPE}" --header "${GITHUB_API_VERSION}" https://api.github.com/repos/"${org}"/"${repo}"/releases/latest)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "Github release list download failed"
      exit 1
    fi

    url="$(echo "${releases}" | yq --input-format json ".assets[] | select(.name == \"*${suffix}.deb\") | .browser_download_url")"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} release url check failed"
      exit 1
    fi

    version="$(echo "${releases}" | yq --input-format json '.name')"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} release version check failed"
      exit 1
    fi

    curl --continue-at - --silent --location "${url}" --output "${targetfolder}"/"${repo}"-"${suffix}".deb
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} download failed"
      exit 1
    fi

    dlname="$(dpkg-deb --field "${targetfolder}"/"${repo}"-"${suffix}".deb package)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package name check failed"
      exit 1
    fi

    dlarch="$(dpkg-deb --field "${targetfolder}"/"${repo}"-"${suffix}".deb architecture)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package architecture check failed"
      exit 1
    fi

    dlversion="$(dpkg-deb --field "${targetfolder}"/"${repo}"-"${suffix}".deb version)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package version check failed"
      exit 1
    fi

    if [ "${version}" != "${dlversion}" ]; then
      logerror "${FUNCNAME[0]}" "${repo} package version invalid (${version}!${dlversion})"
      exit 1
    fi

    if [ "${targetfolder}/${repo}-${suffix}.deb" != "${targetfolder}/${dlname}_${dlversion}_${dlarch}.deb" ]; then
      mv "${targetfolder}/${repo}-${suffix}.deb" "${targetfolder}/${dlname}_${dlversion}_${dlarch}.deb"
      if [ "$?" -ne 0 ]; then
        logerror "${FUNCNAME[0]}" "${repo} package rename failed"
        exit 1
      fi
    fi

    loginfo "${FUNCNAME[0]}" "${repo} package download done"
  else
    logerror "${FUNCNAME[0]}" "package json parameter is missing"
    exit 1
  fi
}

function buildImage {
  loginfo "${FUNCNAME[0]}" "Build the Debian image"

  cd "${BUILD_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${BUILD_DIR} failed"
    exit 1
  fi

  sudo lb build 2>&1 | tee debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"-"${DEBIAN_ARCH}".log
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian image build failed"
    exit 1
  fi

  cd "${WORK_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "cd ${WORK_DIR} failed"
    exit 1
  fi
}

function prepareEnvironment {
  IMAGE_TIMESTAMP="$(date +%Y%m%d%H%M%S)"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "IMAGE_TIMESTAMP env var setup failed"
    exit 1
  fi
  export IMAGE_TIMESTAMP

  if isGithubRunner; then
    loginfo "${FUNCNAME[0]}" "Set Github env vars"

    echo "IMAGE_TIMESTAMP=${IMAGE_TIMESTAMP}" >>"${GITHUB_ENV}"
    echo "RELEASE_VERSION=${RELEASE_VERSION}" >>"${GITHUB_ENV}"
    echo "DEBIAN_VERSION=${DEBIAN_VERSION}" >>"${GITHUB_ENV}"
    echo "DEBIAN_ARCH=${DEBIAN_ARCH}" >>"${GITHUB_ENV}"
    echo "BUILD_DIR=${BUILD_DIR}" >>"${GITHUB_ENV}"
    echo "WORK_DIR=${WORK_DIR}" >>"${GITHUB_ENV}"
  else
    loginfo "${FUNCNAME[0]}" "No Github action, so skip prepareEnvironment"
  fi
}

function fetchRunnerInfos {
  if [ "${RUNNER_SYSINFO}" == "true" ]; then
    loginfo "${FUNCNAME[0]}" "Fetch system infos about the runner environment"

    loginfo "${FUNCNAME[0]}" "query lsb_release -a"
    lsb_release -a
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "lsb_release query failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "query /proc/cpuinfo"
    cat /proc/cpuinfo
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "/proc/cpuinfo query failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "query uname -a"
    uname -a
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "uname query failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "query free -h"
    free -h
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "free query failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "query df -h"
    df -h
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "df query failed"
      exit 1
    fi
  else
    loginfo "${FUNCNAME[0]}" "RUNNER_SYSINFO not enabled"
  fi
}

function cleanupRunner {
  if [ "${RUNNER_CLEANUP}" == "true" ]; then
    loginfo "${FUNCNAME[0]}" "Remove not required folders from the runner environment"

    loginfo "${FUNCNAME[0]}" "remove /opt/hostedtoolcache/CodeQL"
    sudo rm -rf /opt/hostedtoolcache/CodeQL
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "removal of /opt/hostedtoolcache/CodeQL failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "remove /usr/local/lib/android"
    sudo rm -rf /usr/local/lib/android
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "removal of /usr/local/lib/android failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "remove /usr/share/dotnet"
    sudo rm -rf /usr/share/dotnet
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "removal of /usr/share/dotnet failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "remove /usr/local/share/boost"
    sudo rm -rf /usr/local/share/boost
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "removal of /usr/local/share/boost failed"
      exit 1
    fi
  else
    loginfo "${FUNCNAME[0]}" "RUNNER_CLEANUP not enabled"
  fi
}

function installPrerequisites {
  loginfo "${FUNCNAME[0]}" "Install required packages"

  loginfo "${FUNCNAME[0]}" "Fetch live-build.deb from Debian mirror"
  curl --silent --location "${DEBIAN_MIRROR}"/pool/main/l/live-build/live-build_"${DEBIAN_LIVE_BUILD_VERSION}"_all.deb --output /tmp/live-build_"${DEBIAN_LIVE_BUILD_VERSION}"_all.deb
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "live-build.deb fetch failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "Update the apt index"
  sudo apt update --yes
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "apt update failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "Install packages"
  sudo apt install --no-install-recommends --yes /tmp/live-build_"${DEBIAN_LIVE_BUILD_VERSION}"_all.deb debian-archive-keyring
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "apt install failed"
    exit 1
  fi

  for package in "${RUNNER_PACKAGES[@]}"; do
    if dpkg-query --status "${package}" >/dev/null 2>&1; then
      loginfo "${FUNCNAME[0]}" "${package} already installed"
    else
      loginfo "${FUNCNAME[0]}" "${package} not yet installed"
      sudo apt install --no-install-recommends --yes "${package}"
      if [ "$?" -ne 0 ]; then
        logerror "${FUNCNAME[0]}" "${package} install failed"
        exit 1
      fi
    fi
  done

  downloadYq
  downloadTrivy
}

function downloadYq {
  loginfo "${FUNCNAME[0]}" "Install yq"


  sudo curl --silent --location https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${DEBIAN_ARCH} --output /usr/local/bin/yq
  
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "yq download failed"
    exit 1
  fi

  sudo chmod 755 /usr/local/bin/yq
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "yq permission update failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "yq installation done"
}

function downloadTrivy {
  if isGithubRunner; then
    loginfo "${FUNCNAME[0]}" "Install trivy"
    local trivyurl

    trivyurl="$(curl --silent --header "${GITHUB_API_MIMETYPE}" --header "${GITHUB_API_VERSION}" https://api.github.com/repos/aquasecurity/trivy/releases/latest | yq --input-format json '.assets[] | select(.name == "*_Linux-64bit.tar.gz") | .browser_download_url')"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "trivy version check failed"
      exit 1
    fi

    createFolder "${BUILD_DIR}/trivy"

    curl --silent --location "${trivyurl}" --output "${BUILD_DIR}"/trivy/trivy.tar.gz
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "trivy download failed"
      exit 1
    fi

    tar --extract --gzip --no-same-owner --no-same-permissions --file="${BUILD_DIR}"/trivy/trivy.tar.gz --directory "${BUILD_DIR}"/trivy/
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "trivy archive extraction failed"
      exit 1
    fi

    mv "${BUILD_DIR}"/trivy/trivy /usr/local/bin/trivy
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "trivy installation failed"
      exit 1
    fi

    chmod 755 /usr/local/bin/trivy
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "trivy permission update failed"
      exit 1
    fi

    loginfo "${FUNCNAME[0]}" "trivy installation done"
  fi
}

function isGithubRunner {
  if [ -z ${GITHUB_ACTIONS+x} ]; then
    return 1
  else
    return 0
  fi
}

function createChangeLogForRelease {
  loginfo "${FUNCNAME[0]}" "Extract the change description for the release from the CHANGELOG.md"

  grep --perl-regexp --null-data --only-matching "## v${RELEASE_VERSION}[\s\S]*?(?=\n.*?#.{2}|$)" "${WORK_DIR}"/CHANGELOG.md | tr -d '\0' >"${BUILD_DIR}"/changeLogForRelease.md
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "changelog query failed"
    exit 1
  fi

  grep --silent --perl-regexp --null-data --only-matching "## v${RELEASE_VERSION}[\s\S]*?(?=\n.*?#.{2}|$)" "${BUILD_DIR}"/changeLogForRelease.md
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "changeLogForRelease.md does not contain valid content"
    exit 1
  fi

  echo "* ISO image: [iksdp-desktop-${RELEASE_VERSION}](https://${RELEASE_HOST}/debian-live-${DEBIAN_VERSION}-${RELEASE_VERSION}-${IMAGE_TIMESTAMP}-amd64.hybrid.iso)" >>"${BUILD_DIR}"/changeLogForRelease.md
}

function createSourceArchive {
  loginfo "${FUNCNAME[0]}" "Create a source.tar.gz with the current code base"

  tar --create --gzip --file="${BUILD_DIR}"/iksdp-desktop-source-"${RELEASE_VERSION}".tar.gz --directory="${WORK_DIR}" CHANGELOG.md README.md debian-live
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "tar.gz creation failed"
    exit 1
  fi
}

function uploadIso {
  loginfo "${FUNCNAME[0]}" "Upload the ISO to ${RELEASE_HOST}"

  local SSH_PORT=10022
  local SSH_TIMEOUT=60

  createFolder "${HOME}/.ssh"

  eval $(ssh-agent -s)
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "ssh-agent startup failed"
    exit 1
  fi

  ssh-keyscan -p "${SSH_PORT}" -T "${SSH_TIMEOUT}" "${RELEASE_HOST}" >~/.ssh/known_hosts
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "known_hosts configuration failed"
    exit 1
  fi

  echo "${SSH_UPLOAD_KEY}" | tr -d '\r' | ssh-add -
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "ssh-agent config failed"
    exit 1
  fi

  scp -P "${SSH_PORT}" "${BUILD_DIR}"/debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"-"${DEBIAN_ARCH}".hybrid.iso "${RELEASE_USER}"@"${RELEASE_HOST}":"${RELEASE_FOLDER}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "ISO upload failed"
    exit 1
  fi
}

function uploadIsoS3 {
  loginfo "${FUNCNAME[0]}" "Upload the ISO to amazon s3"
 
  sudo snap install aws-cli --classic

  aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
  aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
  aws configure set default.region eu-central-1

  aws s3 cp "${BUILD_DIR}"/debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"-"${DEBIAN_ARCH}".hybrid.iso s3://iksdplinux/
  
  #scp -P "${SSH_PORT}" "${BUILD_DIR}"/debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"-"${DEBIAN_ARCH}".hybrid.iso "${RELEASE_USER}"@"${RELEASE_HOST}":"${RELEASE_FOLDER}"

  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "ISO upload to amazon s3 failed"
    exit 1
  fi
}

function checkChangedFiles {
  loginfo "${FUNCNAME[0]}" "Check for changes in debian-live folder"
  local folderList

  folderList=($(git diff --name-only origin/main..."$(git rev-parse HEAD)"))
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "git diff failed"
    exit 1
  fi

  if [ "${#folderList[*]}" -gt 0 ]; then
    for folder in "${folderList[@]}"; do
      if echo "${folder}" | grep --quiet '^debian-live/*'; then
        echo "run_buildImageRelease=true" >>"${GITHUB_OUTPUT}"
        loginfo "${FUNCNAME[0]}" "run_buildImageRelease=true"
        break
      else
        echo "run_buildImageRelease=false" >>"${GITHUB_OUTPUT}"
        loginfo "${FUNCNAME[0]}" "run_buildImageRelease=false"
      fi
    done
  fi
}

function generateBom {
  loginfo "${FUNCNAME[0]}" "generate bill of materials infos"

  local bomdir

  createFolder "${BUILD_DIR}/mnt"
  createFolder "${BUILD_DIR}/mnt/iso"
  createFolder "${BUILD_DIR}/mnt/squashfs"
  createFolder "${BUILD_DIR}/bom"

  bomdir="${BUILD_DIR}/bom"

  sudo mount --options="loop" "${BUILD_DIR}"/debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"-"${DEBIAN_ARCH}".hybrid.iso "${BUILD_DIR}"/mnt/iso
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "ISO image mount failed"
    exit 1
  fi

  sudo mount --type="squashfs" --options="loop" --source="${BUILD_DIR}/mnt/iso/live/filesystem.squashfs" --target="${BUILD_DIR}/mnt/squashfs"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "squashfs mount failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy cyclonedx BOV generation"
  trivy filesystem --quiet --format cyclonedx --scanners vuln --output "${bomdir}"/bov.cyclone.json "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy cyclonedx BOV generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy cyclonedx BOM generation"
  trivy filesystem --quiet --format cyclonedx --output "${bomdir}"/bom.cyclone.json "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy cyclonedx BOM generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy spdx BOV generation"
  trivy filesystem --quiet --format spdx --scanners vuln --output "${bomdir}"/bov.spdx "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy spdx BOV generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy spdx BOM generation"
  trivy filesystem --quiet --format spdx --output "${bomdir}"/bom.spdx "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy spdx BOM generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy spdx-json BOM generation"
  trivy filesystem --quiet --format spdx-json --output "${bomdir}"/bom.spdx.json "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy spdx-json BOM generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy spdx-json BOV generation"
  trivy filesystem --quiet --format spdx-json --scanners vuln --output "${bomdir}"/bov.spdx.json "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy spdx-json BOV generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy json BOM generation"
  trivy filesystem --quiet --format json --output "${bomdir}"/bom.json "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy json BOM generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "trivy html BOM generation"
  trivy filesystem --quiet --format template --template "@${BUILD_DIR}/trivy/contrib/html.tpl" --output "${bomdir}"/bom.html "${BUILD_DIR}"/mnt/squashfs
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "trivy html BOM generation failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "Debian live package list copy"
  cp "${BUILD_DIR}"/mnt/iso/live/filesystem.packages "${bomdir}"/debian.packages.txt
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian live package list copy failed"
    exit 1
  fi

  loginfo "${FUNCNAME[0]}" "bill of materials generation done"
}

function createFolder {
  if [ -n "${1}" ]; then
    local foldernames rootfolder folderindex foldercount
    IFS=/ read -ra foldernames <<< "${1}"
    rootfolder=""
    folderindex=1
    foldercount=${#foldernames[@]}

    for name in ${foldernames[@]}; do
      (( folderindex++ ))
      rootfolder="${rootfolder}/${name}"

      if [ ! -d "${rootfolder}" ]; then
        mkdir "${rootfolder}"
        if [ "$?" -ne 0 ]; then
          logerror "${FUNCNAME[0]}" "${rootfolder} creation failed"
          exit 1
        fi
        if [ "${folderindex}" -eq "${foldercount}" ]; then
          loginfo "${FUNCNAME[0]}" "${rootfolder} successfully created"
        fi
      fi
    done
  else
    logerror "${FUNCNAME[0]}" "folder name parameter is missing"
    exit 1
  fi
}

function configBootLoader {
  loginfo "${FUNCNAME[0]}" "Configure boot loader"
  local folderlist
  folderlist=("grub-pc" "grub-efi" "isolinux" "syslinux_common")

  for folder in "${folderlist[@]}"; do
    createFolder "${BUILD_DIR}/config/bootloaders/${folder}"
    convert "${WORK_DIR}"/debian-live/config/bootloaders/splash.png -gravity North -pointsize 14 -fill white -annotate +100+100 "Image ${folder} version: ${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}" "${BUILD_DIR}"/config/bootloaders/"${folder}"/splash.png
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${folder} splash screen image generation failed"
      exit 1
    fi
    if [ -d "${WORK_DIR}/debian-live/config/bootloaders/${folder}" ]; then
      cp -r "${WORK_DIR}/debian-live/config/bootloaders/${folder}" "${BUILD_DIR}/config/bootloaders/"
      if [ "$?" -ne 0 ]; then
        logerror "${FUNCNAME[0]}" "${folder} copy to ${BUILD_DIR} failed"
        exit 1
      fi
    fi
  done

  loginfo "${FUNCNAME[0]}" "boot loader configuration done"
}

function setGrubPw {
  loginfo "${FUNCNAME[0]}" "setting grub password"
  GRUB_PASSWORD_HASH="$(echo -e "${ROOTPW}\n${ROOTPW}" | LC_ALL=C /usr/bin/grub-mkpasswd-pbkdf2 | awk '/hash of / {print $NF}')"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "creation of grub password hash failed"
    exit 1
  fi
  if [ -f "${BUILD_DIR}/config/bootloaders/grub-pc/config.cfg" ]; then
    echo "password_pbkdf2 root $GRUB_PASSWORD_HASH" >>  "${BUILD_DIR}"/config/bootloaders/grub-pc/config.cfg
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "adding grub config for password failed"
      exit 1
    fi
  fi
}

importEnvVars
case "${USE_CASE}" in
  "checkChangedFiles")
    checkChangedFiles
    ;;
  "prepareEnvironment")
    checkRootPw
    prepareEnvironment
    ;;
  "fetchRunnerInfos")
    fetchRunnerInfos
    ;;
  "cleanupRunner")
    cleanupRunner
    ;;
  "installPrerequisites")
    createBuildDir
    installPrerequisites
    ;;
  "configImage")
    configBootLoader
    setGrubPw
    configImage
    configPackages
    configHooks
    setRootPw
    configIncludes
    fetchExternalPackages
    createChangeLogForRelease
    createSourceArchive
    ;;
  "buildImage")
    buildImage
    ;;
  "uploadIso")
    uploadIsoS3
    ;;
  "generateBom")
    generateBom
    ;;
  "localBuild")
    checkRootPw
    prepareEnvironment
    createBuildDir
    installPrerequisites
    cleanupConfig
    configImage
    configBootLoader
    setGrubPw
    configPackages
    configHooks
    setRootPw
    configIncludes
    fetchExternalPackages
    buildImage
    ;;
esac
