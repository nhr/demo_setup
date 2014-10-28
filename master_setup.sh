#!/bin/bash

# Make sure Docker is running
#sudo systemctl start docker
#sudo systemctl enable docker

# Make sure OpenShift is running
#sudo systemctl start openshift-master
#sudo systemctl enable openshift-master

# Nuke existing assets
mkdir -p /home/vagrant/.demo_assets
rm -rf ruby-hello-world simple-ruby-app sample-app /home/vagrant/.demo_assets/origin
sudo rm -rf /var/www/html/ruby-hello-word.git

# Pull fresh code
git clone https://github.com/openshift/ruby-hello-world.git
pushd /home/vagrant/.demo_assets
git clone https://github.com/openshift/origin.git
popd
ln -s /home/vagrant/.demo_assets/origin/examples/sample-app

# Create the "local" git repo
sudo yum install -y httpd
sudo mkdir -p /var/www/html/ruby-hello-world.git
pushd /var/www/html/ruby-hello-world.git
sudo git --bare init
sudo mv hooks/post-update.sample hooks/post-update
cd /var/www/html
sudo chmod -R 777 ruby-hello-world.git
popd
sudo systemctl start httpd
sudo systemctl enable httpd
pushd /home/vagrant/ruby-hello-world
git remote add local /var/www/html/ruby-hello-world.git
git push -u local
git push
popd

# Modify the buildCfg
sed -i '8s|.*|        "sourceURI": "http://10.245.1.2/ruby-hello-world.git",|' /home/vagrant/sample-app/application-buildconfig.json

# Update Docker images
/home/vagrant/sample-app/pullimages.sh

# Start demo components
openshift kube apply -c /home/vagrant/sample-app/docker-registry-config.json
openshift kube create buildConfigs -c /home/vagrant/sample-app/application-buildconfig.json

# Define a bash function for triggering builds
if [ -f /home/vagrant/.bashrc ]; then
  cat /home/vagrant/.bashrc | grep simulate_webhook
  if [ $? -ne 0 ]; then
    echo "" >> /home/vagrant/.bashrc
    echo "function simulate_webhook {" >> /home/vagrant/.bashrc
    echo "  curl -s -A \"GitHub-Hookshot/github\" -H \"Content-Type:application/json\" -H \"X-Github-Event:push\" -d @/home/vagrant/sample-app/github-webhook-example.json http://localhost:8080/osapi/v1beta1/buildConfigHooks/build100/secret101/github" >> /home/vagrant/.bashrc
    echo "}" >> /home/vagrant/.bashrc
  fi
fi
