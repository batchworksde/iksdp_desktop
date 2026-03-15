loginfo "fetchExternalPackages" "bitwarden package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "bitwarden package download started"
    curl -s https://api.github.com/repos/bitwarden/clients/releases | jq -r '.[] | .assets[] | select(.name|test("^Bitwarden-.*-amd64\\.deb$")) | "\(.browser_download_url) \(.name)"' | head -n1 | { read url name; new=$(echo "$name" | sed -E 's/.*/\L&/; s/-/_/g'); wget --quiet --no-verbose --output-document="${BUILD_DIR}/config/packages.chroot/$new" "$url"; }
    if [ "$?" -ne 0 ]; then
      logerror "fetchExternalPackages" "bitwarden package download failed"
      exit 1
    fi
    loginfo "fetchExternalPackages" "bitwarden package download done"
else
    loginfo "fetchExternalPackages" "bitwarden package vendor package skipped"
fi