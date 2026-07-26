#!/bin/bash

NETDATA_TOKEN=YOUR_NETDATA_TOKEN
ROOM_ID=YOUR_NETDATA_ROOM_ID

set -e

if systemctl is-active --quiet netdata; then
    echo "Netdata is already installed."
    exit 0
fi

curl -fsSL https://get.netdata.cloud/kickstart.sh -o /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --stable-channel --claim-token "$NETDATA_TOKEN" --claim-rooms "$ROOM_ID" --claim-url https://app.netdata.cloud

sudo systemctl enable netdata
sudo systemctl start netdata

if systemctl is-active --quiet netdata; then
    echo "Netdata installed successfully."
else
    echo "Netdata installation failed."
    exit 1
fi