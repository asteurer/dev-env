#!/bin/bash

#######################################
###        Configure Access         ###
#######################################

echo "### Configure Access ###"

# Remove the ability to log in with a password or as root
sudo sed -i \
    -e 's/#PasswordAuthentication yes/PasswordAuthentication no/g' \
    -e 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' \
    /etc/ssh/sshd_config

#######################################
###        Update Packages          ###
#######################################

echo "### Update Packages ###"
sudo dnf update

#######################################
###          Install git            ###
#######################################

echo "### Install git ###"
sudo dnf install -y git

#######################################
###          Install repo           ###
#######################################

echo "### Install repo ###"
git clone https://github.com/asteurer/dev-env

#######################################
###          Install zsh            ###
#######################################

echo "### Install zsh ###"
sudo dnf install -y zsh

# Make zsh default
sudo usermod --shell /bin/zsh asteurer


#######################################
# Install OhMyZsh
#######################################

echo "### Install OhMyZsh ###"

# Install some helper tools
sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting

# Install OhMyZsh
curl -o install-oh-my-zsh.sh -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install-oh-my-zsh.sh
./install-oh-my-zsh.sh
rm install-oh-my-zsh.sh

# Install the theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Symlink the config files
ln -sf dev-env/.p10k.zsh ~/.p10k.zsh
ln -sf dev-env/.zshrc ~/.zshrc

#######################################
###         Install Docker          ###
#######################################

echo "### Install Docker ###"

    # Remove old versions of Docker
sudo dnf remove docker \
                docker-client \
                docker-client-latest \
                docker-common \
                docker-latest \
                docker-latest-logrotate \
                docker-logrotate \
                docker-selinux \
                docker-engine-selinux \
                docker-engine

sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

#######################################
###        Install Golang           ###
#######################################

echo "### Install Golang ###"

sudo dnf install -y golang

#######################################
###         Install Rust            ###
#######################################

echo "### Install Rust ###"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

#######################################
###         Install tmux            ###
#######################################

echo "### Install tmux ###"

sudo dnf install -y tmux
ln -sf dev-env/.tmux.conf ~/.tmux.conf

# Download and install the plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins all

#######################################
###         Install nvim            ###
#######################################

echo "### Install nvim"
sudo dnf install -y neovim
sudo ln -sf /usr/bin/nvim /usr/bin/vi

#######################################
###      Install 1Password CLI      ###
#######################################
#ARCH="amd64"; \
#OP_VERSION="v$(curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"; \
#    curl -sSfo op.zip \
#    https://cache.agilebits.com/dist/1P/op2/pkg/"$OP_VERSION"/op_linux_"$ARCH"_"$OP_VERSION".zip \
#    && unzip -od /usr/local/bin/ op.zip \
#    && rm op.zip

# You can use `op update`

#######################################
# Install Kubectl
#######################################

#######################################
###      Run CloudFlare Tunnel      ###
#######################################
# docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token $CF_TOKEN
