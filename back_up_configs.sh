# location on ansible controller: ~/homelab-ops/back_up_configs.sh

#!/bin/bash

# Step 1: Source into a particular Python virtual environment
source ~/venvs/ansible/bin/activate

# Step 2: Change into a directory
cd ~/git-workspace/homelab_ops/

# Step 3: Run 2 Ansible playbooks from within the directory
ansible-playbook -T 600 ha-backup.yml -vvv
ansible-playbook -T 600 router-backup.yml -vvv
ansible-playbook -T 600 pihole-backup.yml -vvv
ansible-playbook -T 600 unifi-backup.yml -vvv

# Step 4: Deactivate the virtual environment at the end
deactivate