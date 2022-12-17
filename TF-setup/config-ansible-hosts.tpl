cat << EOF > ../Ansible-setup/hosts

[biznesRadar]
${hostname}

[biznesRadar:vars]
ansible_user=${user}
ansible_ssh_private_key_file=${privateKey}
EOF