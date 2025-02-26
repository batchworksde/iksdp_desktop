loginfo "fetchExternalPackages" "torbrowser package vendor package started"

if [ "${DEBIAN_ARCH}" = "amd64" ]; then
    loginfo "fetchExternalPackages" "torbrowser package download started"

    mkdir -p "${BUILD_DIR}"/cache/
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "creation of cache folder failed"
        exit 1
    fi
    curl --silent --location https://dist.torproject.org/torbrowser/14.0.4/tor-browser-linux-x86_64-14.0.4.tar.xz --output "${BUILD_DIR}"/cache/tor-browser.tar.xz
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "torbrowser package download failed"
        exit 1
    fi
    
    tar xf "${BUILD_DIR}"/cache/tor-browser.tar.xz -C ${BUILD_DIR}"/config/includes.chroot/opt/"
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "torbrowser package extraction failed"
        exit 1
    fi
    chmod -R 755 ${BUILD_DIR}"/config/includes.chroot/opt/tor-browser"
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "torbrowser chmod failed"
        exit 1
    fi

    SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    mkdir -p "${BUILD_DIR}"/config/includes.chroot/opt/iksdp/bin/
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "creation of directory /opt/iksdp/bin in includes.chroot failed"
        exit 1
    fi
    cp "${SCRIPT_DIR}"/start_tor_browser.sh "${BUILD_DIR}"/config/includes.chroot/opt/iksdp/bin/
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "copy of shell script to start torbrowser failed"
        exit 1
    fi

    loginfo "fetchExternalPackages" "torbrowser package download finished"

    mkdir -p "${BUILD_DIR}"/config/includes.chroot/usr/share/applications/
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "creation of folder for gnome applications failed"
        exit 1
    fi
    cat > ${BUILD_DIR}"/config/includes.chroot/usr/share/applications/tor-browser.desktop" <<EOL
[Desktop Entry]
Type=Application
Name=Tor Browser
GenericName=Web Browser
Comment=Tor Browser is +1 for privacy and −1 for mass surveillance
Categories=Network;WebBrowser;Security;
Exec=sh -c "/opt/iksdp/bin/start_tor_browser.sh"
Icon=/opt/tor-browser/Browser/browser/chrome/icons/default/default128.png
StartupNotify=true
StartupWMClass=Tor Browser
EOL
    if [ "$?" -ne 0 ]; then
        logerror "fetchExternalPackages" "creation of desktop file for torbrowser failed"
        exit 1
    fi
fi
