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
###       Install dnf packages      ###
#######################################

sudo dnf -y install \
    helm

#######################################
###       Install aws-creds         ###
#######################################

version=0.1.0
wget https://github.com/asteurer/aws-creds/releases/download/$version/aws-creds-linux-amd64-$version.tar.gz
tar -xvf aws-creds-linux-amd64-$version.tar.gz
sudo mv aws-creds /usr/local/bin
rm aws-creds-linux-amd64-$version.tar.gz

#######################################
###       Install kubectl           ###
#######################################

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

# Validate checksum
if ! echo "$(cat kubectl.sha256) kubectl" | sha256sum --check; then
    echo "Kubectl checksum verification failed! Exiting..."
    exit 1
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Remove files
rm kubectl kubectl.sha256

# I'm setting the .kube/config file to /dev/null to ensure that my `kauth` alias is used instead
mkdir -p ~/.kube
ln -sf /dev/null ~/.kube/config

#######################################
###       Install minio client      ###
#######################################

curl https://dl.min.io/client/mc/release/linux-amd64/mc -o mc
chmod +x mc
sudo mv mc /usr/local/bin

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
# Kubernetes
#-------------------------------------------------------------------------

alias k="kubectl"
# Gather all the paths in ~/.kube that end with ".config" and join them with colons (and removing trailing colon)
alias kauth='export KUBECONFIG="$(find ~/.kube -type f -name "*.config" -printf "%p:")"; export KUBECONFIG="${KUBECONFIG%:}"'
alias kdebug="kubectl run -i --rm --tty debug --image=alpine --restart=Never -- sh"
alias kctx="kubectl config use-context"

#-------------------------------------------------------------------------
# Pulumi
#-------------------------------------------------------------------------

export PATH=$PATH:$HOME/.pulumi/bin
EOF