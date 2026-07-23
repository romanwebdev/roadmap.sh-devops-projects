# Dummy Systemd Service

This project demonstrates how to create and manage a simple custom systemd service on Linux. The service runs a shell script and can be started, stopped, enabled, and monitored with systemd commands.

## Technologies

Shell/Bash, systemd

## Requirements

- [x] Create a shell script named dummy.sh
- [x] Create a systemd service in /etc/systemd/system
- [x] Configure the service to run the script
- [x] Manage the service using systemctl and journalctl

## Steps I Followed

1. Created the directory for the service files in /home/services and added the script file dummy.sh.
   - This directory stores the executable script that the service will run.

2. Created the service definition file dummy.service in /etc/systemd/system.
   - This file tells systemd how to start and manage the service.

3. Added the following configuration to dummy.service:

```ini
[Unit]
Description=Dummy service

[Service]
ExecStart=/home/services/dummy.sh

[Install]
WantedBy=multi-user.target
```

- Description provides a human-readable name for the service.
- ExecStart specifies the command that systemd should run.
- WantedBy=multi-user.target makes the service start automatically in the default multi-user environment.

4. Ran the following commands to register and manage the service:

- Reload systemd so it recognizes the newly created service file.

```bash
sudo systemctl daemon-reload
```

- Enable the service so it starts automatically on boot.

```bash
sudo systemctl enable dummy
```

- Start the service immediately.

```bash
sudo systemctl start dummy
```

- Show the current state of the service.

```bash
sudo systemctl status dummy
```

- Display the service logs in real time.

```bash
sudo journalctl -u dummy -f
```

- Disable the service so it will no longer start automatically on boot.

```bash
sudo systemctl disable dummy
```

- Stop the service manually.

```bash
sudo systemctl stop dummy
```

## Link

[roadmap.sh](https://roadmap.sh/projects/dummy-systemd-service)
