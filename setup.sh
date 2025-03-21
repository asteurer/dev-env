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

echo "### Update Packages ###"
sudo dnf update
sudo dnf install -y \
    git \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    golang \
    tmux \
    neovim


#######################################
###      Install 1Password CLI      ###
#######################################
sudo dnf install -y unzip
ARCH="amd64"; \
OP_VERSION="v$(curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"; \
    curl -sSfo op.zip \
    https://cache.agilebits.com/dist/1P/op2/pkg/"$OP_VERSION"/op_linux_"$ARCH"_"$OP_VERSION".zip \
    && sudo unzip -od /usr/local/bin/ op.zip \
    && rm op.zip


#######################################
###       Install dev-env Repo      ###
#######################################

git clone https://github.com/asteurer/dev-env

#######################################
###         Configure zsh           ###
#######################################

# Make zsh default
sudo usermod --shell /bin/zsh asteurer

#######################################
# Install OhMyZsh
#######################################

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

ln -sf dev-env/.tmux.conf ~/.tmux.conf

# Download and install the plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins all

#######################################
###         Configure nvim          ###
#######################################

sudo ln -sf /usr/bin/nvim /usr/bin/vi

#######################################
###    Install Kubernetes Tools     ###
#######################################

# secure ~/.kube/config
ln -sf /dev/null ~/.kube/config

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
if [[ $(echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check) != "kubectl: OK" ]]; then
    echo "ERROR: kubectl binary didn't match sha256"
    exit 1
fi

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl kubectl.sha256

# helm
sudo dnf install -y helm

#######################################
# Configure git signing and auth keys
# Set up CI for aws-creds tool, and add the install command here
#######################################
