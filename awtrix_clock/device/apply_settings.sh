#!/bin/bash
# Apply AWTRIX device settings from awtrix_settings.json and reboot the clock.
#
# Usage:
#   ./apply_settings.sh <CLOCK_IP>
#   CLOCK_IP=10.0.30.168 ./apply_settings.sh

set -euo pipefail

CLOCK_IP="${1:-${CLOCK_IP:-}}"

if [ -z "$CLOCK_IP" ]; then
  echo "Usage: $0 <CLOCK_IP>"
  echo "   or: CLOCK_IP=<ip> $0"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${SCRIPT_DIR}/awtrix_settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  echo "Settings file not found: $SETTINGS_FILE"
  exit 1
fi

echo "POSTing settings to http://${CLOCK_IP}/api/settings ..."
curl -fsS -X POST -H "Content-Type: application/json" \
  --data-binary "@${SETTINGS_FILE}" \
  "http://${CLOCK_IP}/api/settings"
echo

echo "Rebooting clock at http://${CLOCK_IP}/api/reboot ..."
curl -fsS "http://${CLOCK_IP}/api/reboot" || true
echo
echo "Done."
