#!/bin/bash

#######################################
###        Configure Access         ###
#######################################

# Remove the ability to log in with a password or as root
sudo sed -i \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' \
    /etc/ssh/sshd_config

#######################################
###   Update and Install Packages   ###
#######################################

sudo dnf -y update
sudo dnf -y install \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    golang \
    tmux \
    neovim \
    wget

#######################################
###         Configure zsh           ###
#######################################

# Make zsh default
sudo usermod --shell /bin/zsh $(whoami)

#######################################
# Install OhMyZsh
#######################################

# Install OhMyZsh
curl -o install-oh-my-zsh.sh -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install-oh-my-zsh.sh
./install-oh-my-zsh.sh --unattended
rm install-oh-my-zsh.sh

# Install the theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Symlink the config files
ln -sf $(pwd)/.p10k.zsh ~/.p10k.zsh
ln -sf $(pwd)/.zshrc ~/.zshrc

#######################################
###         Install Docker          ###
#######################################

sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

#######################################
###         Install Rust            ###
#######################################

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

#######################################
###         Configure tmux          ###
#######################################

ln -sf $(pwd)/.tmux.conf ~/.tmux.conf

# Download and install the plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins all

#######################################
###         Configure nvim          ###
#######################################

sudo ln -sf /usr/bin/nvim /usr/bin/vi

#######################################
###         Configure git           ###
#######################################

ln -sf $(pwd)/.gitconfig ~/.gitconfig

#######################################
###       Install aws-creds         ###
#######################################

version=0.1.0
wget https://github.com/asteurer/aws-creds/releases/download/$version/aws-creds-linux-amd64-$version.tar.gz
tar -xvf aws-creds-linux-amd64-$version.tar.gz
sudo mv aws-creds /usr/local/bin

#######################################
###       Install kubeconfig        ###
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