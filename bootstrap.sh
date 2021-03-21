#!/bin/bash
# Installing and


curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - 
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" 
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
apt-get -y update && apt-get install -y terraform  docker-ce-cli


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 
cp kubectl /usr/local/bin/kubectl
chmod 755 /usr/local/bin/kubectl
cp .bashrc /root/.bashrc
source config.tfvars
