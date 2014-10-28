#!/bin/bash

basedir=`dirname $0`

if [ ! -d origin ]; then
  git clone https://github.com/openshift/origin
fi
cd origin
export OPENSHIFT_DEV_CLUSTER=1 
vagrant up

# Check for / setup SSH config file
mkdir -p ~/.ssh
if [ -f ~/.ssh/config ]; then
  cat ~/.ssh/config | grep 10.245
  if [ $? -ne 0 ]; then
    echo "" >> ~/.ssh/config
    vagrant ssh-config >> ~/.ssh/config
  fi
else
  vagrant ssh-config >> ~/.ssh/config
fi
chmod 600 ~/.ssh/config

cd ..

# Copy the git config to the master instance
scp ${basedir}/git_config master:~/.gitconfig

# Run each setup script
echo "Running setup on Vagrant hosts."
ssh master 'bash -s' < ${basedir}/master_setup.sh &
ssh minion-1 'bash -s' < ${basedir}/minion_setup.sh &
ssh minion-2 'bash -s' < ${basedir}/minion_setup.sh &
wait
echo "Setup completed."
exit
