#!/bin/bash

set -e

DURATION=30

if ! command -v stress-ng >/dev/null 2>&1; then
    echo "stress-ng not found. Installing..."
    sudo apt update
    sudo apt install -y stress-ng
fi

echo "Generating CPU load for ${DURATION} seconds..."
stress-ng --cpu 0 --timeout "${DURATION}s" --metrics-brief

echo "Done! Check the Netdata dashboard to verify CPU usage and other system metrics."