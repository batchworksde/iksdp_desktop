#!/bin/bash
# Configure br0 bridge
apt-get update
apt-get install -y bridge-utils

# Bring down the interface
ip link set dev enp2s0 down

# Create and configure the bridge
brctl addbr br0
brctl addif br0 enp2s0
ip link set dev br0 up

# Obtain an IP address
dhclient br0
