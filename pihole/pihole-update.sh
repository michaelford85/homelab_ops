#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/home/ford/git-workspace/homelab_ops/pihole/update_gravity_logs/"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"

exec >>"$LOG_FILE" 2>&1

echo "==== Gravity update for $1 started at $(date) ===="

export ANSIBLE_CONFIG=/home/ford/git-workspace/homelab_ops/pihole/ansible.cfg

exec /home/ford/.venvs/ansible/bin/ansible-playbook \
  -i /home/ford/git-workspace/homelab_ops/pihole/inventory \
  /home/ford/git-workspace/homelab_ops/pihole/update-pihole.yml \
  --limit "$1" -v

echo "==== Gravity update for $1 finished at $(date) ===="