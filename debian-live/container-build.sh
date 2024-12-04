#! /usr/bin/env bash

set -e
set -u
set -o pipefail


declare CONTAINERCOMMAND

function showHelp {
  echo -e "Usage: $(basename $0) [OPTION]"
  echo -e ""
  echo -e "This script is supposed to be run from the root directory."
  echo -e "Running the script without any options starts the building process of the iksdp image."
  echo -e ""
  echo -e "  -a, --all      Configure, build bootstrap image and run it"
  echo -e "  -b, --build    Configure and build bootstrap image"
  echo -e "  -h, --help     Show this message"
  echo -e "  -r, --run      Run bootstrap container"
  echo -e ""
  echo -e "Building the bootstrap image copies the Containerfile.template to Containerfile and"
  echo -e "replaces {{ IMAGE_OPTIONS }} with options set during the image configuration. The base"
  echo -e "of the image is DEBIAN_VERSION from build.env."
}

function checkContainerCommand {
  if [ $(command -v podman) 2>&1>/dev/null ]; then
    CONTAINERCOMMAND=podman
  else
    CONTAINERCOMMAND=docker
  fi
}

function buildBootstrapImage {
  local useAptCacheAnswer=""
  local useAptCache=true
  local aptCacheUrlAnswer=""
  local aptCacheUrl="http://localhost:3142"
  local containerfileTemplatePath="$(pwd)/debian-live/Containerfile.template"
  local containerfilePath="$(pwd)/debian-live/Containerfile"
  local imageOptions=""

  if [ ! -f "${containerfileTemplatePath}" ]; then
    echo "Containerfile.template not found at ${containerfileTemplatePath}."
    exit 1
  fi

  read -n 1 -p "Use apt caching proxy (highly recommended)? [Y|n]: " useAptCacheAnswer
  case "${useAptCacheAnswer,,}" in #${,,} converts to lower case
    ""|"y")
      read -p $'\n'"Apt caching proxy URL [http://localhost:3142]: " aptCacheUrlAnswer
      if [ "${aptCacheUrlAnswer}" ]; then
        aptCacheUrl="${aptCacheUrlAnswer}"
      fi
      ;;
    "n"|"N")
      useAptCache=false
      ;;
    *)
      echo -e "\nUnknown option. Valid options are: 'Y', 'y', 'N', 'n'"
      exit 1
      ;;
  esac

  cp "${containerfileTemplatePath}" "${containerfilePath}"
  if [ "$?" -ne 0 ]; then
    echo "Failed to copy container template file."
    exit 1
  fi

  if [ "$useAptCache" = true ]; then
    imageOptions="RUN echo 'Acquire::http { Proxy \"${aptCacheUrl}\"; };' > /etc/apt/apt.conf.d/51acng"
    sed "s|{{ IMAGE_OPTIONS }}|${imageOptions}|" -i "${containerfilePath}"
  else
    sed "s|{{ IMAGE_OPTIONS }}||" -i "${containerfilePath}"
  fi

  source debian-live/build.env

  sudo $CONTAINERCOMMAND build \
    --build-arg debian_version="${DEBIAN_VERSION}" \
    --network host \
    -t iksdp_desktop-builder \
    -f "${containerfilePath}" \
    debian-live
}

function runBootstrapContainer {
  sudo $CONTAINERCOMMAND run \
    --rm \
    --network host \
    --privileged \
    --volume $(pwd):/iksdp_desktop \
    iksdp_desktop-builder:latest
}


checkContainerCommand

if [ "$#" -eq 0 ]; then
  runBootstrapContainer
fi

case "$@" in
  -a|--all)
    buildBootstrapImage
    runBootstrapContainer
    ;;
  -b|--build)
    buildBootstrapImage
    ;;
  -h|--help)
    showHelp
    ;;
  -r|--run)
    runBootstrapContainer
    ;;
esac
