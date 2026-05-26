# homelab_ops


Prerequisites for ansible controller
- Install Ansible-core on Ansible Controller
- apt install sshpass
- pip install pyexpect

## Repository structure

```
homelab_ops/
├── back_up_configs.sh           wrapper that runs the three backup playbooks
├── pihole-backup.yml            Pi-hole Teleporter backup -> NAS
├── unifi-backup.yml             UniFi autobackup -> NAS
├── router-backup.yml            EdgeRouter config backup -> NAS
├── ha-backup.yml                Home Assistant config backup
├── raspbian-upgrade.yml         apt upgrade for Raspbian Pis
├── office-pis-update-ubuntu.yml apt upgrade for Ubuntu Pis
└── awtrix_clock/                version-controlled Ulanzi TC001 / AWTRIX 3 config
```

## awtrix_clock/

Configuration for the Ulanzi TC001 pixel clock running AWTRIX 3, integrated
with Home Assistant over MQTT. Contains the templated HA automations and
scripts, the device `/api/settings` payload plus an apply-and-reboot script,
and notes for the manual UI helpers and LaMetric icons. See
`awtrix_clock/README.md` for the from-scratch setup sequence.