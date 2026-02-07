# location on ansible controller: ~/homelab-ops/back_up_configs.sh

#!/bin/bash

# Step 1: Source into a particular Python virtual environment
source ~/.venvs/ansible/bin/activate

# Step 2: Change into a directory
# cd ~/git-workspace/homelab_ops/
cd /workspace/git-workspace/homelab_ops/

# Step 3: Run 2 Ansible playbooks from within the directory
ansible-playbook -T 600 router-backup.yml -v
ansible-playbook -T 600 pihole-backup.yml -v
ansible-playbook -T 600 unifi-backup.yml -v
ansible-playbook -T 600 jellyfin-backup.yml -v
# Step 4: Deactivate the virtual environment at the end
deactivate