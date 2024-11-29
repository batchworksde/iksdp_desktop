#!/usr/bin/env bash
set +e
set -u
set -o pipefail

declare USE_CASE WORK_DIR BUILD_DIR

USE_CASE=${1-localBuild}
WORK_DIR="$(pwd)"
BUILD_DIR="${HOME}/build"
DEBIAN_ARCH=$(dpkg --print-architecture)

export USE_CASE WORK_DIR BUILD_DIR DEBIAN_ARCH

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
  source "${WORK_DIR}"/debian-live/build.env && IMAGE_TIMESTAMP=$(date +%Y%m%d%H%M%S)
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Environment variables import failed"
    exit 1
  fi
}

function createBuildDir {
  loginfo "${FUNCNAME[0]}" "Creating build directory"

  if [ ! -d "${BUILD_DIR}" ]; then
    mkdir "${BUILD_DIR}"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "build directory creation failed"
      exit 1
    fi
  fi
}

function cleanupConfig {
  loginfo "${FUNCNAME[0]}" "Clean up build directory"
  cd "${BUILD_DIR}"
  sudo lb clean
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "live-build cleanup failed"
    exit 1
  fi

  if [ -d "${BUILD_DIR}"/config/ ]; then
    rm -r "${BUILD_DIR}"/config/
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "config dir removal failed"
      exit 1
    fi
  fi

  cd "${WORK_DIR}"
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
    --backports false \
    --updates true \
    --security true \
    --architectures "${DEBIAN_ARCH}" \
    --apt-recommends true \
    --apt-indices false \
    --cache true \
    --cache-packages true\
    --checksums "sha256" \
    --chroot-squashfs-compression-level "${DEBIAN_SQUASHFS_COMPRESSION_LEVEL}" \
    --chroot-squashfs-compression-type "${DEBIAN_SQUASHFS_COMPRESSION_TYPE}" \
    --compression xz \
    --zsync false \
    --archive-areas "main non-free-firmware" \
    --bootappend-live "boot=live config locales=${DEBIAN_LOCALES} keyboard-layouts=${DEBIAN_KEYBOARD_LAYOUTS} timezone=${DEBIAN_TIMEZONE} ${liveConfigOptions}" \
    --image-name debian-live-"${DEBIAN_VERSION}"-"${RELEASE_VERSION}"-"${IMAGE_TIMESTAMP}"
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "Debian image configuration failed"
    exit 1
  fi
  cd "${WORK_DIR}"
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



  if [ "$DEBIAN_ARCH" == "amd64" ]; then    
    curl --silent --location https://zoom.us/client/"${DEBIAN_ZOOM_VERSION}"/zoom_amd64.deb --output "${BUILD_DIR}"/config/packages.chroot/zoom_amd64.deb
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "Zoom client download failed"
      exit 1
    fi
    loginfo "${FUNCNAME[0]}" "Zoom package download done"
  fi

  curl --silent --location http://iksdp.pfadfinderzentrum.org/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/icaclient_24.8.0.98_"${DEBIAN_ARCH}".deb
  loginfo "${FUNCNAME[0]}" "icaclient package download done"
  #curl --silent --location https://github.com/IsmaelMartinez/teams-for-linux/releases/download/v1.11.3/teams-for-linux_1.11.3_"${DEBIAN_ARCH}".deb --output "${BUILD_DIR}"/config/packages.chroot/teams-for-linux_1.11.3_"${DEBIAN_ARCH}".deb
  #loginfo "${FUNCNAME[0]}" "teams package download done"

  #downloadGithubRelease rustdesk rustdesk latest "x86_64"
}

function downloadGithubRelease {
  if [ -n "${1}" ] && [ -n "${2}" ] && [ -n "${3}" ] && [ -n "${4}" ]; then
    local repo org version apiversion apimimetype targetfolder dlversion dlname dlarch
    repo="${1}"
    org="${2}"
    version="${3}"
    suffix="${4}"
    apiversion="X-GitHub-Api-Version: 2022-11-28"
    apimimetype="Accept: application/vnd.github+json"
    targetfolder="${BUILD_DIR}/config/packages.chroot"

    if [ "${version}" == "latest" ]; then
      version="$(curl --silent --header "${apimimetype}" --header "${apiversion}" https://api.github.com/repos/"${org}"/"${repo}"/releases/latest | jq -r .name)"
      if [ "$?" -ne 0 ]; then
        logerror "${FUNCNAME[0]}" "${repo} release version check failed"
        exit 1
      fi
    fi

    curl --silent --location https://github.com/"${org}"/"${repo}"/releases/download/"${version}"/"${repo}"-"${version}"-"${suffix}".deb --output "${targetfolder}/${repo}-${suffix}.deb"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} download failed"
      exit 1
    fi

    dlname="$(dpkg-deb --field ${targetfolder}/${repo}-${suffix}.deb name)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package check failed"
      exit 1
    fi

    dlarch="$(dpkg-deb --field ${targetfolder}/${repo}-${suffix}.deb architecture)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package check failed"
      exit 1
    fi

    dlversion="$(dpkg-deb --field ${targetfolder}/${repo}-${suffix}.deb version)"
    if [ "$?" -ne 0 ]; then
      logerror "${FUNCNAME[0]}" "${repo} package check failed"
      exit 1
    fi

    if [ "${version}" != "${dlversion}" ]; then
      logerror "${FUNCNAME[0]}" "${repo} package version invalid (${version}!${dlversion})"
      exit 1
    fi

    if [ "${targetfolder}/${repo}-${suffix}.deb" != "${targetfolder}/${dlname}_${dlversion}_${dlarch}.deb" ]; then
      mv "${targetfolder}/${repo}-${suffix}.deb" "${targetfolder}/${dlname}_${dlversion}_${dlarch}.deb"
      if [ "${version}" != "${dlversion}" ]; then
        logerror "${FUNCNAME[0]}" "${repo} package rename failed"
        exit 1
      fi
    fi
    
    loginfo "${FUNCNAME[0]}" "${repo} package download done"
  else
    logerror "${FUNCNAME[0]}" "at least one parameter is missing"
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
  cd "${WORK_DIR}"
}

function prepareEnvironment {
  if [ -z ${GITHUB_ACTIONS+x} ]; then
    loginfo "${FUNCNAME[0]}" "No Github action, so skip prepareEnvironment"
  else
    loginfo "${FUNCNAME[0]}" "Set Github env vars"

    echo "IMAGE_TIMESTAMP=${IMAGE_TIMESTAMP}" >>"${GITHUB_ENV}"
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
}

function createSourceArchive {
  loginfo "${FUNCNAME[0]}" "Create a source.tar.gz with the current code base"

  tar --create --gzip --file="${BUILD_DIR}"/iksdp-desktop-source-"${RELEASE_VERSION}".tar.gz --directory="${WORK_DIR}" CHANGELOG.md README.md debian-live
  if [ "$?" -ne 0 ]; then
    logerror "${FUNCNAME[0]}" "tar.gz creation failed"
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
  "localBuild")
    prepareEnvironment
    installPrerequisites
    createBuildDir
    cleanupConfig
    configImage
    configPackages
    configHooks
    fetchExternalPackages
    buildImage
    ;;
esac
