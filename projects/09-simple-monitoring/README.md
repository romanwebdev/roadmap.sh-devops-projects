# Simple Monitoring

## Environment

- **Cloud Provider:** AWS
- **Instance:** EC2
- **Operating System:** Ubuntu 26.04 LTS
- **Monitoring Tool:** Netdata
- **Testing Tool:** stress-ng

---

## Goal

The goal of this project is to learn the basics of system monitoring by installing and configuring **Netdata** on a Linux server.

The project includes:

- Installing Netdata
- Accessing the monitoring dashboard
- Monitoring system metrics
- Customizing the dashboard
- Creating a CPU usage alert
- Automating installation, testing, and cleanup with shell scripts

---

## Step 1. Install Netdata

The Ubuntu repositories did not contain the required package, so the official Netdata installation script was used.

Download the installer:

```bash
curl -fsSL https://get.netdata.cloud/kickstart.sh -o /tmp/netdata-kickstart.sh
```

Run the installer:

```bash
sh /tmp/netdata-kickstart.sh \
    --stable-channel \
    --claim-token "$NETDATA_TOKEN" \
    --claim-rooms "$ROOM_ID" \
    --claim-url https://app.netdata.cloud
```

Enable and start the service:

```bash
sudo systemctl enable netdata
sudo systemctl start netdata
```

Verify installation:

```bash
systemctl status netdata
```

or

```bash
systemctl is-active netdata
```

---

## Step 2. Configure AWS Security Group

Netdata continued to use its default port:

```
19999
```

Added an inbound rule to the EC2 Security Group:

| Type       | Protocol | Port  |
| ---------- | -------- | ----- |
| Custom TCP | TCP      | 19999 |

Dashboard:

```
http://<EC2_PUBLIC_IP>:19999
```

---

## Step 3. Explore the Dashboard

Verified monitoring of:

- CPU
- Memory
- Disk I/O
- Network Traffic

Observed live metrics while the server was idle.

---

## Step 4. Install stress-ng

```bash
sudo apt update
sudo apt install -y stress-ng
```

Generate CPU load:

```bash
stress-ng --cpu 0 --timeout 30s --metrics-brief
```

Explanation:

- `--cpu 0` → use all available CPU cores
- `--timeout 30s` → stop automatically after 30 seconds
- `--metrics-brief` → print execution statistics

Verified CPU usage increased in the Netdata dashboard.

---

## Step 5. Customize the Dashboard

Customized the dashboard by:

- Changing the default time range
- Marking favorite charts
- Reordering dashboard sections

---

## Step 6. Configure CPU Alert

Located the default alert configuration:

```text
/usr/lib/netdata/conf.d/health.d/cpu.conf
```

Created a custom configuration:

```bash
sudo mkdir -p /etc/netdata/health.d

sudo cp /usr/lib/netdata/conf.d/health.d/cpu.conf \
    /etc/netdata/health.d/
```

Modified the alert to trigger on a **1-minute average** instead of the default 10-minute average.

Original:

```text
lookup: average -10m
```

Modified:

```text
lookup: average -1m
```

Updated the warning threshold:

```text
warn: $this > (($status >= $WARNING) ? (70) : (80))
```

Restarted Netdata:

```bash
sudo systemctl restart netdata
```

Generated CPU load again with `stress-ng` and confirmed the alert was triggered.

---

## Step 7. Automation Scripts

## setup.sh

```bash
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
```

---

## test_dashboard.sh

```bash
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
```

---

## cleanup.sh

```bash
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
```

---

## Outcome

Successfully completed a basic monitoring setup using **Netdata**.

Implemented:

- Real-time system monitoring
- Dashboard customization
- CPU alerting
- CPU load testing with `stress-ng`
- Automated installation
- Automated testing
- Automated cleanup

This project provided practical experience with Linux services, monitoring concepts, AWS networking, alert configuration, and Bash automation.

---

## Link

[roadmap.sh](https://roadmap.sh/projects/simple-monitoring-dashboard)
