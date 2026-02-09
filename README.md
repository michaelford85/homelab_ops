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
├── os_updates/
│   ├── office-pis-update-ubuntu.yml
│   └── infra01-update-ubuntu.yml
├── ansible.cfg
├── inventory
├── requirements.yml
├── back_up_configs.sh
├── jellyfin-backup.yml
├── pihole-backup.yml
├── router-backup.yml
├── unifi-backup.yml
├── raspbian-upgrade.yml
├── default.config.yml
├── custom.config.yml
└── README.md
```

---

## Typical usage

### Homelab OS Updates

The raspberry Pis running Ubuntu in my office are upgraded with the following command:

```bash
ansible-playbook os_updates/office-pis-update-ubuntu.yml
```

The infra01 main homelab server is upgraded with the following:

```bash
ansible-playbook os_updates/infra01-update-ubuntu.yml -K 
```
> -K tells the playbook to prompt for the sudo password

### Ad-hoc usage

Most workflows are kicked off via the helper script:

```bash
./back_up_configs.sh
```

Playbooks can also be run directly:

```bash
ansible-playbook jellyfin-backup.yml
```

---

## Scheduled runs (systemd timers)

Scheduled automation in this repository is implemented using **systemd services and timers**, rather than cron.

Systemd timers provide several advantages over cron:

- Explicit working directories and environments
- First-class logging via `journald`
- No missed-run edge cases
- `Persistent=true` support (catch up after downtime)
- Clear introspection via `systemctl`

Each scheduled task is defined as a **oneshot service** paired with a **timer**.

---

### Homelab backups

Backups are executed by a dedicated systemd service which runs the helper script:

```
back_up_configs.sh
```

Schedule:
- **Every Monday at 02:30 AM**
- Uses `Persistent=true` so a missed run executes on next boot

Each run generates its own timestamped log file under:

```
backup_logs/
```

Relevant units:

```
/etc/systemd/system/homelab-backup.service
/etc/systemd/system/homelab-backup.timer
```

Manual test run:

```bash
sudo systemctl start homelab-backup.service
```

View logs:

```bash
journalctl -u homelab-backup.service
```

---

### Pi-hole gravity updates

Pi-hole gravity updates are also managed via systemd services and timers.

Separate services are used for each Pi-hole instance to allow independent schedules and failure isolation.

| Target            | Schedule       |
|-------------------|----------------|
| pihole_server     | Daily at 04:00 |
| pihole2_server    | Daily at 05:00 |

Each service runs the same Ansible playbook with a different inventory limit.

Relevant units:

```
/etc/systemd/system/pihole-update-pihole_server.service
/etc/systemd/system/pihole-update-pihole_server.timer

/etc/systemd/system/pihole-update-pihole2_server.service
/etc/systemd/system/pihole-update-pihole2_server.timer
```

Manual test run:

```bash
sudo systemctl start pihole-update-pihole_server.service
sudo systemctl start pihole-update-pihole2_server.service
```

View logs:

```bash
journalctl -u pihole-update-pihole_server.service
journalctl -u pihole-update-pihole2_server.service
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

Common dependencies include:

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
