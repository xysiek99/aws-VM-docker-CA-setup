#!/bin/bash

# Before running remember to set correct 
# home IP address in TF-setup/variables.tf

echo "1. Create key pair for ssh if not exists"
PRIV_KEY=~/.ssh/test_vm_key
PUB_KEY=~/.ssh/test_vm_key.pub

if [ ! -f $PRIV_KEY ] || [ ! -f $PUB_KEY ]
then
    echo "Public, private or both keys don't exist - creating new key pair"
    rm --force $PRIV_KEY
    rm --force $PUB_KEY
    ssh-keygen -b 4096 -t rsa -f $PRIV_KEY -q -N ""
else
    echo "Public and private keys exist - omitting creation"	
fi

echo "2. Init terraform"
cd TF-setup
terraform init

echo "3. Setting up infrastructure with TF"
terraform apply -auto-approve

echo "4. Giving time to let finish setup"
sleep 30

echo "5. Installing Docker on VM with Ansible"
cd ../Ansible-setup
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook main.yml -i hosts

echo "6. Creating CA authority and self-signed cert with Ansible"
ansible-playbook createCAandSSLcert.yml -i hosts
