#!/bin/bash

# Check to see whether the domain is accessible from port 6443
read -p "Domain or IP address: " ip_addr
timeout 1 bash -c "cat < /dev/null > /dev/tcp/$ip_addr/6443" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "ERROR: port 6443 is not accessible on host '$ip_addr'"
    exit 1
fi

# Confirm the SSH connection
while [ true ]
do
    read -p "Confirm SSH connection for '$ip_addr'? [y/N] " confirm_ssh
    case $confirm_ssh in
        y|Y|[Yy][Ee][Ss]) break;;
        n|N|[Nn][Oo]|"") exit 0;;
        * ) echo "Please answer yes or no";;
    esac
done

read -p "Server username: " user
read -p "Name of the config: " name

mkdir -p ~/.kube

# Retrieve and edit kubeconfig file
script_dir=$(dirname $(readlink -f $0))
ssh $user@$ip_addr 'sudo cat /etc/rancher/k3s/k3s.yaml' | python3 $script_dir/edit_k3s_kubeconfig.py $ip_addr $name > ~/.kube/$name.config