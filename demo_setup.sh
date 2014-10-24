#!/bin/bash

# Check for / setup SSH config file
if [ -f ~/.ssh/config ]; then
  cat ~/.ssh/config | grep 10.245
  if [ $? -ne 0 ]; then
    echo "" >> ~/.ssh/config
    cat ssh_config >> ~/.ssh/config
  fi
else
  cp ssh_config ~/.ssh/config
fi
chmod 600 ~/.ssh/config

# Copy the git config to the master instance
scp git_config demo_master:~/.gitconfig

# Run each setup script
echo "Running setup on Vagrant hosts."
ssh demo_master 'bash -s' < master_setup.sh &
ssh demo_minion-1 'bash -s' < minion_setup.sh &
ssh demo_minion-2 'bash -s' < minion_setup.sh &
wait
echo "Setup completed."
exit
