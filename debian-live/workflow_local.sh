#!/usr/bin/env bash

# sudo apt update
# sudo apt --yes install git curl sudo xz-utils
debian-live/build.sh prepareEnvironment
debian-live/build.sh installPrerequisites
debian-live/build.sh configImage
debian-live/build.sh buildImage
