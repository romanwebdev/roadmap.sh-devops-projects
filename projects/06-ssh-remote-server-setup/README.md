# SSH Remote Server Setup

## Environment

- Cloud provider: **AWS**
- Instance: **EC2**, running **Ubuntu**
- Local machine: **Windows** (using PowerShell with built-in OpenSSH client)

## Goal

Set up a remote Linux server and configure it to allow SSH connections using two separate SSH key pairs, plus enable connection via an alias through `~/.ssh/config`.

---

## Steps Performed

### 1. Initial connection using the AWS-generated key

AWS provides a `.pem` private key file when launching an EC2 instance. This was used for the first connection:

```bash
ssh -i <path-to-pem-file> ubuntu@<server-ip>
```

### 2. Generated two new SSH key pairs

Created two independent key pairs locally (separate from the original `.pem` file), using Windows-style paths:

```powershell
ssh-keygen -t ed25519 -f C:\Users\<you>\.ssh\devops_key1 -C "devops-key1"
ssh-keygen -t ed25519 -f C:\Users\<you>\.ssh\devops_key2 -C "devops-key2"
```

This produced four files:

- `devops_key1` — **private key** (kept secret, never shared, stays only on the local machine)
- `devops_key1.pub` — **public key** (safe to share, gets copied to the server's `authorized_keys`)
- `devops_key2` — **private key**
- `devops_key2.pub` — **public key**

### 3. Added both public keys to the server

Connected to the instance using the original `.pem` file, then appended the contents of both new `.pub` files to the server's `authorized_keys` file:

```bash
nano ~/.ssh/authorized_keys
```

Pasted in the contents of `devops_key1.pub` and `devops_key2.pub`, each on its own line, without removing the existing entries. Confirmed correct permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

**Result:** the server now accepts three separate keys — the original `.pem` and the two new ones — all valid at the same time.

### 4. Verified both new keys work for connecting

From the local Windows machine:

```powershell
ssh -i C:\Users\<you>\.ssh\devops_key1 ubuntu@<server-ip>
ssh -i C:\Users\<you>\.ssh\devops_key2 ubuntu@<server-ip>
```

Both connected successfully without needing the original `.pem` file.

### 5. Configured `~/.ssh/config` for alias-based connection

Edited the SSH config file (same location and syntax on Windows and Linux, just different path root):

```
Host myserver
    HostName <server-ip>
    User ubuntu
    IdentityFile C:\Users\<you>\.ssh\devops_key1
    IdentitiesOnly yes
```

Verified permissions on the config file:

```bash
chmod 600 ~/.ssh/config
```

Tested the alias connection:

```powershell
ssh myserver
```

Successfully connected to the server using just the alias, without specifying the key path or IP manually.

### 6. Installed and configured fail2ban

Installed `fail2ban` on the Ubuntu server to protect against brute-force SSH login attempts:

```bash
sudo apt update
sudo apt install fail2ban -y
```

Created a local jail configuration:

```bash
sudo nano /etc/fail2ban/jail.local
```

```ini
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
findtime = 600
```

Enabled and started the service:

```bash
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban
```

Verified it was running and monitoring SSH:

```bash
sudo fail2ban-client status sshd
```

---

## Outcome

- Able to SSH into the AWS EC2 Ubuntu instance using **two separate self-generated SSH keys**, in addition to the original AWS `.pem` key.
- Able to connect using a short alias (`ssh myserver`) via `~/.ssh/config`.
- `fail2ban` installed and configured on the server to guard SSH against brute-force attacks.

## Link

[roadmap.sh](https://roadmap.sh/projects/ssh-remote-server-setup)
