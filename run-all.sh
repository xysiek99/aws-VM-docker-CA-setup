#!/bin/bash

# Before running remember to set correct 
# home IP address in TF-setup/variables.tf

echo "1. Create key pair for ssh"
ssh-keygen -b 4096 -t rsa -f ~/.ssh/test_vm_key -q -N ""

echo "2. Setting up infrastructure with TF"
cd TF-setup
terraform apply -auto-approve

echo "3. Installing Docker on VM with Ansible"
cd ../Ansible-setup
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook main.yml -i hosts

echo "4. Creating CA authority and self-signed cert with Ansible"
ansible-playbook createCAandSSLcert.yml -i hosts