#!/bin/bash

# Make sure docker is running
sudo systemctl start docker
sudo systemctl enable docker

# Make sure OpenShift is running
sudo systemctl start openshift-node
sudo systemctl enable openshift-node

# Load the docker-builder
docker pull openshift/docker-builder
