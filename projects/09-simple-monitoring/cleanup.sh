#!/bin/bash

set -e

echo "Stopping Netdata..."
if systemctl is-active --quiet netdata; then
    sudo systemctl stop netdata
    sudo systemctl disable netdata
fi

echo "Removing Netdata packages..."
if dpkg -l | grep -q "^ii  netdata"; then
    sudo apt remove -y \
        netdata \
        netdata-dashboard \
        netdata-plugin-* \
        netdata-user \
        netdata-repo

    sudo apt autoremove -y
fi

echo "Removing stress-ng..."
sudo apt remove -y stress-ng

echo "Cleanup completed successfully."