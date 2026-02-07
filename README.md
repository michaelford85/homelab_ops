# homelab_ops

A personal Ansible-based operations repository for managing and maintaining a small homelab.

This repo contains playbooks and helper scripts for **backups, updates, and routine maintenance** across media servers, DNS infrastructure, Raspberry Pis, and network devices. It reflects real-world usage rather than an abstract “Ansible best practices” showcase.

---

## Goals

- Automate routine homelab operations
- Make backups consistent, versioned, and auditable
- Minimize manual intervention and configuration drift
- Document operational intent for future maintenance

This repository is primarily designed for my own infrastructure, but it may be useful as a reference or starting point for others running similar setups.

---

## Repository structure

```
homelab_ops/
├── collections/
├── pihole/
│   └── update-pihole.yml
├── ansible.cfg
├── inventory
├── requirements.yml
├── back_up_configs.sh
├── jellyfin-backup.yml
├── pihole-backup.yml
├── router-backup.yml
├── unifi-backup.yml
├── office-pis-update-ubuntu.yml
├── raspbian-upgrade.yml
├── default.config.yml
├── custom.config.yml
└── README.md
```

---

## Typical usage

### Ad-hoc usage
Most workflows are kicked off via the helper script:

```bash
./back_up_configs.sh
```

Playbooks can also be run directly:

```bash
ansible-playbook jellyfin-backup.yml
```

### Scheduled Runs

If you want to run in a scheduled fashion, you can use CRON by editing your crontab:

```bash
crontab -e
```

Note: cron does not set a working directory like an interactive shell does.
If your scripts or playbooks rely on relative paths, you must cd into the repo first (or make the script cd into its own directory internally).

Example crontab entries:

```
# Use bash for consistency (cron defaults to /bin/sh)
SHELL=/bin/bash

# (Optional) Set a predictable PATH for cron
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Run the back_up_configs.sh script every Monday at 2:30 AM.
# NOTE: We cd into the repo so ansible/playbook relative paths resolve correctly.
30 2 * * 1 cd /home/ford/git-workspace/homelab_ops && /bin/bash ./back_up_configs.sh >> /home/ford/git-workspace/homelab_ops/backup_logs/backup_$(date +\%Y-\%m-\%d_\%H-\%M-\%S).log 2>&1

# Update Gravity on pihole_server every day at 4:00 AM.
# Appends to a rolling log file (not timestamped).
0 4 * * * export ANSIBLE_CONFIG=/home/ford/git-workspace/homelab_ops/pihole/ansible.cfg && /home/ford/.venvs/ansible/bin/ansible-playbook -i /home/ford/git-workspace/homelab_ops/pihole/inventory /home/ford/git-workspace/homelab_ops/pihole/update-pihole.yml --limit pihole_server -v >> /home/ford/git-workspace/homelab_ops/pihole/pihole_update_ansible.log 2>&1

# Update Gravity on pihole2_server every day at 5:00 AM.
# Appends to the same rolling log file.
0 5 * * * export ANSIBLE_CONFIG=/home/ford/git-workspace/homelab_ops/pihole/ansible.cfg && /home/ford/.venvs/ansible/bin/ansible-playbook -i /home/ford/git-workspace/homelab_ops/pihole/inventory /home/ford/git-workspace/homelab_ops/pihole/update-pihole.yml --limit pihole2_server -v >> /home/ford/git-workspace/homelab_ops/pihole/pihole_update_ansible.log 2>&1
```

Before enabling scheduled backups, ensure the log directory exists:

```
mkdir -p /home/ford/git-workspace/homelab_ops/backup_logs
```
---

## Example: Jellyfin backup

The Jellyfin backup playbook demonstrates the general pattern used throughout this repository:

1. Inspect the running Docker container
2. Extract the exact Jellyfin server version from OCI image labels
3. Stop the container briefly to ensure data consistency
4. Recursively copy configuration and data directories
5. Restart the container
6. Create a timestamped, versioned archive
7. Upload the archive to off-host storage (typically a NAS)
8. Clean up temporary files

---

## Inventory and configuration

- `inventory` defines hosts and groups
- `default.config.yml` contains default values
- `custom.config.yml` is used for environment-specific overrides and is not committed


---

## Requirements

Install required collections before running playbooks:

```bash
ansible-galaxy install -r requirements.yml
```

Common dependencies include the following ansible collections:

- community.docker
- community.general
- ansible.posix

---

## Assumptions

- Linux-based Ansible control node
- Linux hosts (Ubuntu, Raspbian)
- Docker for application services
- SSH key-based authentication
- Off-host backup storage

---

## Philosophy

This repository favors:

- Explicit playbooks over heavy abstraction
- Readability over cleverness
- Repeatability over speed
- Capturing operational intent alongside automation

---

## License

Provided as-is for personal and educational use.
