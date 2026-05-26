#!/usr/bin/env bash
set -u -o pipefail  # note: no -e

LOG_DIR="/home/ford/git-workspace/homelab_ops/backup_logs"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOG_FILE="${LOG_DIR}/backup_${TIMESTAMP}.log"

mkdir -p "$LOG_DIR"
exec >>"$LOG_FILE" 2>&1

echo "==== Backup started at $(date) ===="

source ~/.venvs/ansible/bin/activate
cd /home/ford/git-workspace/homelab_ops

fail=0

run_pb() {
  local name="$1"
  shift
  echo
  echo "---- Running: $name ----"
  "$@"
  local rc=$?
  if (( rc != 0 )); then
    echo "!!!! FAILED: $name (rc=$rc) — continuing"
    fail=1
  else
    echo "OK: $name"
  fi
}

run_pb "pihole-backup"   ansible-playbook -T 600 pihole-backup.yml -vv
run_pb "router-backup"   ansible-playbook -T 600 router-backup.yml -vv
run_pb "unifi-backup"    ansible-playbook -T 600 unifi-backup.yml -vv
run_pb "jellyfin-backup" ansible-playbook -T 600 jellyfin-backup.yml -vv

deactivate || true
echo "==== Backup finished at $(date) ===="

exit "$fail"