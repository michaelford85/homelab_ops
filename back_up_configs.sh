#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/home/ford/git-workspace/homelab_ops/backup_logs"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

exec >>"$LOG_FILE" 2>&1

echo "==== Backup started at $(date) ===="

# Step 1: Source into a particular Python virtual environment
source ~/.venvs/ansible/bin/activate

# Step 2: Change into a directory
# cd ~/git-workspace/homelab_ops/
cd /home/ford/git-workspace/homelab_ops

# Step 3: Run 2 Ansible playbooks from within the directory
ansible-playbook -T 600 router-backup.yml -v
ansible-playbook -T 600 pihole-backup.yml -v
ansible-playbook -T 600 unifi-backup.yml -v
ansible-playbook -T 600 jellyfin-backup.yml -v
# Step 4: Deactivate the virtual environment at the end
deactivate

echo "==== Backup finished at $(date) ===="