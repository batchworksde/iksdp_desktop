#!/usr/bin/env bash
set +e
set -u
set -o pipefail

declare USE_CASE WORK_DIR BUILD_DIR

USE_CASE=${1}
WORK_DIR="$(pwd)"
BUILD_DIR="${HOME}/build"

export USE_CASE WORK_DIR BUILD_DIR

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

function importEnvVars {
  loginfo "${FUNCNAME[0]}" "Loading 'build.env' environment variables"
  set -a # automatically export all variables
  source "${WORK_DIR}"/debian-live/build.env
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Environment variables import failed"
    exit 1
  fi
  set +a
}

function createBuildDir {
  loginfo "${FUNCNAME[0]}" "Creating build directory"
  mkdir -p "${BUILD_DIR}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "build directory creation failed"
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
    liveConfigOptions+=" persistence"
  else
    liveConfigOptions+=" nopersistence"
  fi

  cd "${BUILD_DIR}"
  lb config \
    --distribution "${DEBIAN_VERSION}" \
    --mirror-bootstrap "${DEBIAN_MIRROR}" \
    --mirror-chroot "${DEBIAN_MIRROR}" \
    --mirror-binary "${DEBIAN_MIRROR}" \
    --mirror-chroot-security "${DEBIAN_SEC_MIRROR}" \
    --mirror-binary-security "${DEBIAN_SEC_MIRROR}" \
    --backports true \
    --updates true \
    --security true \
    --architectures "${DEBIAN_ARCH}" \
    --apt-recommends true \
    --apt-indices false \
    --cache false \
    --checksums "sha256" \
    --chroot-squashfs-compression-level "${DEBIAN_SQUASHFS_COMPRESSION_LEVEL}" \
    --chroot-squashfs-compression-type "${DEBIAN_SQUASHFS_COMPRESSION_TYPE}" \
    --compression xz \
    --archive-areas "main non-free-firmware" \
    --bootappend-live "boot=live config hostname=iksdp-${RELEASE_VERSION} locales=${DEBIAN_LOCALES} keyboard-layouts=${DEBIAN_KEYBOARD_LAYOUTS} timezone=${DEBIAN_TIMEZONE} ${liveConfigOptions}" \
    --image-name debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian image configuration failed"
    exit 1
  fi
}

function configBootSplash {
  loginfo "${FUNCNAME[0]}" "Configure boot splash"
  mkdir -p "${BUILD_DIR}"/config/bootloaders/grub-pc
  # debug output package list
  dplg -l 
  # imagemagick is needed
  convert "${WORK_DIR}"/debian-live/config/bootloaders/grub-pc/splash.png -gravity North -pointsize 14 -fill white -annotate +100+100 "Image version: ${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"  "${BUILD_DIR}"/config/bootloaders/grub-pc/splash.png

  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "create spash screen failed"
    exit 1
  fi
}

function configPackages {
  loginfo "${FUNCNAME[0]}" "Configure Debian package list"
  cp "${WORK_DIR}"/debian-live/config/package-lists/*.chroot "${BUILD_DIR}"/config/package-lists/
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian package list config failed"
    exit 1
  fi
}

function configHooks {
  loginfo "${FUNCNAME[0]}" "Configure Debian Live build hooks"
  cp "${WORK_DIR}"/debian-live/config/hooks/normal/*.hook.chroot "${BUILD_DIR}"/config/hooks/normal/
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian Live hook config failed"
    exit 1
  fi
}

function fetchExternalPackages {
  loginfo "${FUNCNAME[0]}" "Fetch external Debian packages"
  curl --silent --location https://zoom.us/client/"${DEBIAN_ZOOM_VERSION}"/zoom_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/zoom_amd64.deb
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Zoom client download failed"
    exit 1
  fi
}

function buildImage {
  loginfo "${FUNCNAME[0]}" "Build the Debian image"
  cd "${BUILD_DIR}"
  sudo lb build 2>&1 | tee debian-live-"${DEBIAN_VERSION}"-"${DEBIAN_ARCH}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}".log
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian image build failed"
    exit 1
  fi
}

function prepareEnvironment {
  loginfo "${FUNCNAME[0]}" "Set Github env vars"

  echo "IMAGE_TIMESTAMP=$(date +%Y%m%d%H%M%S)" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "IMAGE_TIMESTAMP env var setup failed"
    exit 1
  fi

  echo "RELEASE_VERSION=${RELEASE_VERSION}" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "RELEASE_VERSION env var setup failed"
    exit 1
  fi

  echo "DEBIAN_VERSION=${DEBIAN_VERSION}" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "DEBIAN_VERSION env var setup failed"
    exit 1
  fi

  echo "DEBIAN_ARCH=${DEBIAN_ARCH}" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "DEBIAN_VERSION env var setup failed"
    exit 1
  fi

  echo "BUILD_DIR=${BUILD_DIR}" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "BUILD_DIR env var setup failed"
    exit 1
  fi

  echo "WORK_DIR=${WORK_DIR}" >>"${GITHUB_ENV}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "WORK_DIR env var setup failed"
    exit 1
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
  sudo apt install --no-install-recommends --yes /tmp/live-build_"${DEBIAN_LIVE_BUILD_VERSION}"_all.deb debian-archive-keyring "${RUNNER_PACKAGES}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "apt install failed"
    exit 1
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

  echo "* ISO image: [iksdp-desktop-${RELEASE_VERSION}](http://${RELEASE_HOST}/debian-live-${DEBIAN_VERSION}-${RELEASE_VERSION}-${IMAGE_TIMESTAMP}-amd64.hybrid.iso)" >>"${BUILD_DIR}"/changeLogForRelease.md
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "adding ISO image link to release notes failed"
    exit 1
  fi
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

  mkdir -p ~/.ssh/

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

importEnvVars
case "${USE_CASE}" in
  "prepareEnvironment")
    prepareEnvironment
    ;;
  "fetchRunnerInfos")
    fetchRunnerInfos
    ;;
  "cleanupRunner")
    cleanupRunner
    ;;
  "installPrerequisites")
    installPrerequisites
    ;;
  "configImage")
    createBuildDir
    configImage
    configBootSplash
    configPackages
    configHooks
    fetchExternalPackages
    createSourceArchive
    createChangeLogForRelease
    ;;
  "buildImage")
    buildImage
    ;;
  "uploadIso")
    uploadIso
    ;;
esac
