#!/usr/bin/env bash

# sudo apt update
# sudo apt --yes install git curl sudo xz-utils
if [ -f "/tmp/IMAGE_TIMESTAMP" ]; then
  rm "/tmp/IMAGE_TIMESTAMP"
fi
if command -v lb >/dev/null 2>&1; then
  CURRENT_DIR="$(pwd)"
  cd "${HOME}/build"
  sudo lb clean
  cd "${CURRENT_DIR}"
fi

debian-live/build.sh installPrerequisites
debian-live/build.sh configImage
debian-live/build.sh buildImage
