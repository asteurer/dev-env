#!/bin/bash

#######################################
###      Run shared scripts         ###
#######################################
./../shared/shared_setup.sh

#######################################
###        Configure Access         ###
#######################################
# Remove the ability to log in with a password or as root (this only applies to ssh servers)
sshd_config="/etc/ssh/sshd_config"
if [[ -f "$sshd_config" ]]; then
    sudo sed -i \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' \
    $sshd_config
fi

#######################################
###       Install aws-creds         ###
#######################################
version=0.1.0
wget https://github.com/asteurer/aws-creds/releases/download/$version/aws-creds-linux-amd64-$version.tar.gz
tar -xvf aws-creds-linux-amd64-$version.tar.gz
sudo mv aws-creds /usr/local/bin
rm aws-creds-linux-amd64-$version.tar.gz

#######################################
###          Install pulumi         ###
#######################################
curl -fsSL https://get.pulumi.com | sh

#######################################
###    Addtl config for .zshrc      ###
#######################################
# Create a copy of the .zshrc.template file
cp ../shared/.zshrc.template ../shared/.zshrc

# Append local config
cat >> ../shared/.zshrc <<'EOF'
#-------------------------------------------------------------------------
# Pulumi
#-------------------------------------------------------------------------
export PATH=$PATH:$HOME/.pulumi/bin

EOF
