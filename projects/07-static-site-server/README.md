# Static Site Server

## Environment

- Remote server: AWS EC2 instance, Ubuntu, accessed via SSH
- Local machine: used for editing the site and running the deploy script
- Web server: nginx
- Deployment: rsync over SSH

## Goal

Serve a simple static site (HTML/CSS/images) from the EC2 instance's public IP using nginx, with a repeatable `rsync`-based script to push local changes to the server.

## 1. Server setup (EC2, Ubuntu)

Connected via SSH (instance already provisioned with SSH access).

Installed nginx:

```bash
sudo apt update
sudo apt install -y nginx
```

Opened port 80 (HTTP): AWS Console → EC2 → Instances → select instance → Security tab → click the security group → Edit inbound rules → Add rule → Type: HTTP, Port 80, Source: Anywhere (0.0.0.0/0) → Save.

## 2. Site directory on the server

```bash
sudo mkdir -p /var/www/site
sudo chown -R ubuntu:ubuntu /var/www/site
```

Ownership set to the SSH user so rsync can write without `sudo`.

## 3. Nginx server block

Created `/etc/nginx/sites-available/site`:

```nginx
server {
    listen 80;
    server_name YOUR_EC2_IP;

    root /var/www/site;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

Enabled it and removed the default site:

```bash
sudo ln -s /etc/nginx/sites-available/site /etc/nginx/sites-enabled/site
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## 4. Local static site

Created a minimal project locally:

```
site/
├── index.html
└── css/
|    └── style.css
└── laptop.png
```

Basic HTML page with a stylesheet and simple image.

## 5. Deploy script

`deploy.sh` (kept alongside `site/`, not inside it) uses `rsync` over SSH to sync the local folder to the server:

```bash
#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="ubuntu"
REMOTE_HOST="YOUR_EC2_IP"
SSH_KEY="$HOME/.ssh/your-key.pem"
REMOTE_PATH="/var/www/site/"
LOCAL_DIR="site/"

rsync -avz --delete \
  -e "ssh -i $SSH_KEY" \
  "$LOCAL_DIR" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"
```

Run with:

```bash
chmod +x deploy.sh
./deploy.sh
```

## Outcome

Static site served from the EC2 instance's public IP via nginx, with `./deploy.sh` as the repeatable rsync deploy step for future changes.

## Link

[roadmap.sh](https://roadmap.sh/projects/static-site-server)
