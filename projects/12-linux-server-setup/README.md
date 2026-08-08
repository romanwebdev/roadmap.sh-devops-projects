# Linux Server Setup

## Overview

This project demonstrates the basic hardening and configuration of a fresh Ubuntu Linux server running on an AWS EC2 instance.

The goal is to transform a newly provisioned server into a more secure and production-ready administration host by configuring secure SSH access, a restrictive firewall, automatic security updates, brute-force protection, system settings, service management, and log inspection.

The project was performed on:

- **Cloud:** AWS EC2
- **OS:** Ubuntu 26.04 LTS
- **Instance type:** `t3.small`
- **Hostname:** `devops-server`
- **Timezone:** UTC

---

## Goals

The main goals of the project were to:

- Create a non-root administrative user.
- Configure SSH key-based authentication.
- Disable password-based SSH authentication.
- Disable direct SSH access for root.
- Configure UFW with a default-deny incoming policy.
- Allow SSH traffic through the firewall.
- Keep the system packages updated.
- Configure automatic security updates.
- Install and configure Fail2Ban for SSH protection.
- Configure a meaningful hostname and timezone.
- Practice basic `systemctl` service management.
- Learn how to inspect system logs using `journalctl` and `/var/log`.

---

## Requirements

- AWS account or another cloud provider
- Fresh Ubuntu server
- SSH access to the server
- Local SSH client
- `sudo` privileges

---

# Implementation

## 1. Initial Server Verification

Before making any changes, the server environment was inspected.

Useful commands:

```bash
whoami
hostname
cat /etc/os-release
uname -a
sudo whoami
```

This confirmed that the server was running Ubuntu 26.04 LTS and that the initial administrative access was through the `ubuntu` user.

---

## 2. Create a Non-Root Administrative User

A dedicated user named `devops` was created for future server administration.

The user was added to the `sudo` group:

```bash
sudo usermod -aG sudo devops
```

The user was then tested:

```bash
su - devops
```

Verify the current user:

```bash
whoami
```

Expected:

```text
devops
```

Verify sudo access:

```bash
sudo whoami
```

Expected:

```text
root
```

The purpose of this configuration is to avoid using the root account directly for normal administration.

---

## 3. Configure SSH Key Authentication

An SSH key pair was generated on the local Windows machine:

```text
devops_key1
devops_key1.pub
```

The public key was added to:

```text
/home/devops/.ssh/authorized_keys
```

The SSH directory and key file permissions were configured as:

```text
.ssh              → 700
authorized_keys   → 600
```

The ownership was:

```text
devops:devops
```

Verification:

```bash
ls -ld /home/devops/.ssh
ls -l /home/devops/.ssh/authorized_keys
```

The result was:

```text
drwx------ ... devops devops ... /home/devops/.ssh
-rw------- ... devops devops ... /home/devops/.ssh/authorized_keys
```

SSH access was then tested from the local machine using the private key:

```powershell
ssh -i ~/.ssh/devops_key1 devops@<EC2_PUBLIC_IP>
```

The connection was successfully established as the `devops` user.

---

## 4. Harden SSH Configuration

The effective SSH configuration was inspected before making changes:

```bash
sudo sshd -T | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin)'
```

The server already had:

```text
pubkeyauthentication yes
passwordauthentication no
permitrootlogin prohibit-password
```

Password-based SSH authentication was therefore already disabled.

A separate hardening configuration was created:

```text
/etc/ssh/sshd_config.d/99-hardening.conf
```

with:

```text
PermitRootLogin no
```

The configuration was validated before reloading SSH:

```bash
sudo sshd -t
```

The effective configuration was then checked again:

```bash
sudo sshd -T | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin)'
```

Final configuration:

```text
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
```

SSH was reloaded and a new SSH connection was tested successfully.

The resulting administration model is:

```text
SSH key
   ↓
devops
   ↓
sudo
   ↓
root
```

Direct root SSH access and password-based SSH authentication are disabled.

---

## 5. Configure UFW Firewall

The initial UFW status was checked:

```bash
sudo ufw status verbose
```

The firewall was initially inactive.

The default policies were configured:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

SSH was explicitly allowed:

```bash
sudo ufw allow 22/tcp
```

The rule was inspected before enabling the firewall:

```bash
sudo ufw show added
```

UFW was then enabled:

```bash
sudo ufw enable
```

Final firewall status:

```bash
sudo ufw status verbose
```

Result:

```text
Status: active
Default: deny (incoming), allow (outgoing)

22/tcp ALLOW IN Anywhere
22/tcp (v6) ALLOW IN Anywhere (v6)
```

A new SSH connection was tested after enabling the firewall to confirm that SSH remained accessible.

The firewall therefore follows a **default-deny** model:

```text
Incoming traffic
      │
      ├── TCP 22 → ALLOW
      │
      └── Everything else → DENY
```

Additional application ports such as HTTP (`80`) and HTTPS (`443`) can be added later when required.

---

## 6. System Updates

The package information was refreshed:

```bash
sudo apt update
```

Available package upgrades were inspected:

```bash
apt list --upgradable
```

System packages were then upgraded:

```bash
sudo apt upgrade
```

Keeping the system updated reduces exposure to known vulnerabilities and ensures that installed software receives current fixes.

---

## 7. Configure Automatic Security Updates

The `unattended-upgrades` package was already installed on the Ubuntu server.

Its status was checked with:

```bash
apt policy unattended-upgrades
```

The automatic update configuration was inspected:

```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
```

The server contained:

```text
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

This configures daily package-list updates and daily unattended upgrades.

The allowed update origins were configured in:

```text
/etc/apt/apt.conf.d/50unattended-upgrades
```

The systemd timers were verified:

```bash
systemctl list-timers --all | grep -E 'apt|unattended'
```

The automatic upgrade timer was also checked:

```bash
systemctl status apt-daily-upgrade.timer
```

The timer was:

```text
enabled
active (waiting)
```

This confirmed that automatic update processing is scheduled and enabled at boot.

---

## 8. Install and Configure Fail2Ban

Fail2Ban was not initially installed.

The package was installed:

```bash
sudo apt install fail2ban
```

The service was verified:

```bash
sudo systemctl status fail2ban
```

The service was:

```text
active (running)
enabled
```

Fail2Ban already had an SSH jail enabled.

The configured jails were checked:

```bash
sudo fail2ban-client status
```

Result:

```text
Number of jail: 1
Jail list: sshd
```

The SSH jail was inspected:

```bash
sudo fail2ban-client status sshd
```

The jail monitors the SSH service through the systemd journal.

The configured retry limit was checked:

```bash
sudo fail2ban-client get sshd maxretry
```

Result:

```text
5
```

The ban duration was checked:

```bash
sudo fail2ban-client get sshd bantime
```

Result:

```text
600
```

Therefore, the configured behavior is approximately:

```text
5 failed SSH attempts
        ↓
Fail2Ban detects repeated failures
        ↓
IP address is banned
        ↓
10-minute ban
```

No IP addresses were banned during testing.

---

## 9. Configure Hostname and Timezone

The initial hostname was the AWS-generated hostname:

```text
ip-172-31-34-18
```

A meaningful hostname was configured:

```bash
sudo hostnamectl set-hostname devops-server
```

Verification:

```bash
hostnamectl
hostname
```

Final hostname:

```text
devops-server
```

The system timezone was inspected:

```bash
timedatectl
```

The server uses:

```text
Etc/UTC
```

UTC was retained because it is commonly used for servers and simplifies correlation of logs across systems and environments.

Time synchronization was also verified:

```text
System clock synchronized: yes
NTP service: active
```

---

## 10. Service Management with systemctl

The Fail2Ban service was used to practice basic systemd service management.

Check service status:

```bash
sudo systemctl status fail2ban
```

Stop a service:

```bash
sudo systemctl stop fail2ban
```

Start a service:

```bash
sudo systemctl start fail2ban
```

Check whether a service is enabled at boot:

```bash
sudo systemctl is-enabled fail2ban
```

The final result was:

```text
enabled
```

The project demonstrated the distinction between:

```text
systemctl start/stop
```

which affects the current runtime state, and:

```text
systemctl enable/disable
```

which affects whether a service starts automatically during boot.

---

## 11. Inspect System Logs with journalctl

The systemd journal was inspected using:

```bash
sudo journalctl -n 20
```

This displayed recent system events including service starts, `sudo` activity, and system processes.

Service-specific logs were inspected with:

```bash
sudo journalctl -u fail2ban
```

and:

```bash
sudo journalctl -u ssh -n 20
```

The SSH journal showed successful public-key authentication:

```text
Accepted publickey for devops
```

This provided direct evidence that SSH key authentication was working.

The journal also showed SSH service start/stop events and Fail2Ban activity.

---

## 12. Inspect `/var/log`

The traditional Linux log directory was inspected:

```bash
ls -lah /var/log/
```

Important log locations on this server include:

```text
/var/log/auth.log
/var/log/syslog
/var/log/kern.log
/var/log/dpkg.log
/var/log/apt/
/var/log/fail2ban.log
/var/log/unattended-upgrades/
/var/log/cloud-init.log
/var/log/cloud-init-output.log
/var/log/dmesg
/var/log/journal/
```

Examples:

Authentication and SSH-related logs:

```bash
sudo tail -n 20 /var/log/auth.log
```

Fail2Ban logs:

```bash
sudo tail -n 20 /var/log/fail2ban.log
```

General system logs:

```bash
sudo tail -n 20 /var/log/syslog
```

Automatic update logs:

```bash
sudo ls -lah /var/log/unattended-upgrades/
```

---

# Final Verification

The final SSH configuration was verified with:

```bash
sudo sshd -T | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin)'
```

Result:

```text
permitrootlogin no
pubkeyauthentication yes
passwordauthentication no
```

Firewall:

```bash
sudo ufw status verbose
```

Result:

```text
Status: active
Default: deny (incoming), allow (outgoing)

22/tcp ALLOW IN Anywhere
22/tcp (v6) ALLOW IN Anywhere (v6)
```

Fail2Ban:

```bash
sudo fail2ban-client status sshd
```

Result:

```text
Jail: sshd
Currently banned: 0
```

Boot-time service status:

```bash
systemctl is-enabled fail2ban
```

Result:

```text
enabled
```

Hostname and time:

```bash
hostname
timedatectl
```

Result:

```text
Hostname: devops-server
Timezone: UTC
System clock synchronized: yes
NTP service: active
```

---

# Outcome

A fresh Ubuntu EC2 server was configured with a basic production-oriented security baseline.

The final server provides:

- A dedicated non-root administrative user with `sudo` privileges.
- SSH key-based authentication.
- Disabled password-based SSH authentication.
- Disabled direct root SSH access.
- UFW configured with a default-deny incoming policy.
- SSH explicitly allowed through the firewall.
- Updated system packages.
- Daily automatic security update processing.
- Fail2Ban protection for SSH brute-force attempts.
- A meaningful hostname.
- UTC timezone and active NTP synchronization.
- Basic systemd service-management experience.
- System and service log inspection using `journalctl`.
- Familiarity with common logs under `/var/log`.

The server is now prepared as a hardened base system for future application deployment.

---

## Link

[roadmap.sh](https://roadmap.sh/projects/linux-server-setup)
