cat << EOF > ../Ansible-setup/hosts

[testVM]
${hostname}

[testVM:vars]
ansible_user=${user}
ansible_ssh_private_key_file=${privateKey}
EOF