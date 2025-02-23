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
    neovim \
    htop


#######################################
###          Configure git          ###
#######################################

git config --global user.email "94206073+asteurer@users.noreply.github.com"
git config --global user.name "Andrew Steurer"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/gh_sign
git config --global commit.gpgsign true
git config --global core.editor "nvim -f"

# Figure out how to sign commits using the op cli

#######################################
###      Install 1Password CLI      ###
#######################################

# Place the OP_SERVICE_ACCOUNT_TOKEN
if $OP_SERVICE_ACCOUNT_TOKEN == ""; then
    echo "Missing `OP_SERVICED_ACCOUNT_TOKEN`"
    exit 1
fi
mkdir -p ~/.1password
echo "$OP_SERVICE_ACCOUNT_TOKEN" > ~/.1password/op_service_account_token
chmod 400 ~/.1password/op_service_account_token # read-only by owner

sudo dnf install -y unzip
ARCH="amd64"; \
OP_VERSION="v$(curl https://app-updates.agilebits.com/check/1/0/CLI2/en/2.0.0/N -s | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')"; \
    curl -sSfo op.zip \
    https://cache.agilebits.com/dist/1P/op2/pkg/"$OP_VERSION"/op_linux_"$ARCH"_"$OP_VERSION".zip \
    && sudo unzip -od /usr/local/bin/ op.zip \
    && rm op.zip

#######################################
###      Install dev-env Repo       ###
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
ln -sf dev-env/.zshrc_fedora_server ~/.zshrc

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
###      Run CloudFlare Tunnel      ###
#######################################

# If this doesn't work the first time, try regenerating the credential, entering it into 1Password, and try again
# sudo docker run -d cloudflare/cloudflared:latest tunnel \
#    --no-autoupdate run \
#    --token $(op item get dev_env_cf_tunnel_token --fields label=credential --vault DEV --reveal)

#######################################
# Install Kubectl
# Configure git signing and auth keys
# Configure SSHing into a cloudflare tunnel instance
#######################################
