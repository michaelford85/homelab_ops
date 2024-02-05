# location on ansible controller: ~/homelab-ops/back_up_configs.sh

#!/bin/bash

# Step 1: Source into a particular Python virtual environment
source ~/venvs/ansible_core_0214/bin/activate

# Step 2: Change into a directory
cd ~/git-workspace/homelab_ops/

# Step 3: Run 2 Ansible playbooks from within the directory
ansible-playbook pihole-backup.yml
ansible-playbook unifi-backup.yml
ansible-playbook ha-backup.yml

# Step 4: Deactivate the virtual environment at the end
deactivate