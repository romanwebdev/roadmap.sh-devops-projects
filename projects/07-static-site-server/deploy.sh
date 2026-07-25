#!/usr/bin/env bash
set -euo pipefail

# --- config: edit these ---
REMOTE_USER="ubuntu"
REMOTE_HOST="YOUR_EC2_IP"
SSH_KEY="$HOME/.ssh/ssh-aws-key.pem"
REMOTE_PATH="/var/www/site/"
LOCAL_DIR="site/"
# ---------------------------

rsync -avz --delete \
  -e "ssh -i $SSH_KEY" \
  "$LOCAL_DIR" \
  "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH"