#!/bin/bash

# Define the directory path to check
TOR_BROWSER_PATH="$HOME/.local/share/torbrowser/tbb/x86_64"

# Check if the directory exists
if [ -d "$TOR_BROWSER_PATH" ]; then
    echo "Tor Browser directory exists: $TOR_BROWSER_PATH"
    $TOR_BROWSER_PATH/tor-browser/Browser/start-tor-browser --detached
else
    echo "Tor Browser directory does not exist: $TOR_BROWSER_PATH"
    mkdir -p $TOR_BROWSER_PATH
    cp -a /opt/tor-browser/ $TOR_BROWSER_PATH
    $TOR_BROWSER_PATH/tor-browser/Browser/start-tor-browser --detached
fi
