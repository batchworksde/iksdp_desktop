loginfo "fetchExternalPackages" "torbrowser package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "torbrowser package download started"

    curl --continue-at - --silent --location https://dist.torproject.org/torbrowser/14.0.4/tor-browser-linux-x86_64-14.0.4.tar.xz --output "${BUILD_DIR}"/cache/tor-browser.tar.xz
    
    tar xf "${BUILD_DIR}"/cache/tor-browser.tar.xz -C ${BUILD_DIR}"/config/includes.chroot/opt/"
    chmod -R 755 ${BUILD_DIR}"/config/includes.chroot/opt/tor-browser"

    SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    mkdir -p "${BUILD_DIR}"/config/includes.chroot/opt/iksdp/bin/
    cp "${SCRIPT_DIR}"/start_tor_browser.sh "${BUILD_DIR}"/config/includes.chroot/opt/iksdp/bin/

    loginfo "fetchExternalPackages" "torbrowser package download finished"

    mkdir -p "${BUILD_DIR}"/config/includes.chroot/usr/share/applications/
    cat > ${BUILD_DIR}"/config/includes.chroot/usr/share/applications/tor-browser.desktop" <<EOL
[Desktop Entry]
Type=Application
Name=Tor Browser
GenericName=Web Browser
Comment=Tor Browser  is +1 for privacy and −1 for mass surveillance
Categories=Network;WebBrowser;Security;
Exec=sh -c "/opt/iksdp/bin/start_tor_browser.sh"
Icon=/opt/tor-browser/Browser/browser/chrome/icons/default/default128.png
StartupNotify=true
StartupWMClass=Tor Browser
EOL
fi


