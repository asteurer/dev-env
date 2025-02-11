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

if which dnf; then
    sudo dnf update
elif which apt; then
    sudo apt update
    sudo apt upgrade
    sudo snap refresh
fi

#######################################
###          Install git            ###
#######################################

echo "### Install git ###"

if which dnf; then
    sudo dnf install -y git
elif which apt; then
    sudo apt install -y git
else
    echo "Missing `dnf` or `apt` package manager"
    exit 1
fi


#######################################
###          Install repo           ###
#######################################

echo "### Install repo ###"

git clone https://github.com/asteurer/dev-env

#######################################
###          Install zsh            ###
#######################################

echo "### Install zsh ###"

if which dnf; then
    sudo dnf install -y zsh
elif which apt; then
    sudo apt install -y zsh
else
    echo "Missing `dnf` or `apt` package manager"
    exit 1
fi

# Symlink the config file
ln -sf dev-env/.zshrc ~/.zshrc


#######################################
# Install OhMyZsh
#######################################

echo "### Install OhMyZsh ###"

# Install some helper tools
sudo dnf install zsh-autosuggestions zsh-syntax-highlighting

# Install OhMyZsh
curl -o install-oh-my-zsh.sh -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install-oh-my-zsh.sh
./install-oh-my-zsh.sh
rm install-oh-my-zsh.sh

# Install the theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Symlink the config file
ln -sf dev-env/.p10k.zsh ~/.p10k.zsh

#######################################
###         Install Docker          ###
#######################################

echo "### Install Docker ###"

if which apt; then
    # Remove old versions of Docker
    for pkg in \
        docker.io \
        docker-doc \
        docker-compose \
        docker-compose-v2 \
        podman-docker \
        containerd \
        runc;
    do sudo apt remove $pkg;
    done

    # Add Docker's official GPG key:
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update

elif which dnf; then
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
else
    echo "Missing `dnf` or `apt` package manager"
    exit 1
fi

#######################################
###        Install Golang           ###
#######################################

echo "### Install Golang ###"

if which dnf; then
    sudo dnf install -y golang
elif which snap; then
    sudo snap install go
else
    echo "Missing `dnf` or `snap` package manager"
    exit 1
fi

#######################################
###         Install Rust            ###
#######################################

echo "### Install Rust ###"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

#######################################
###         Install tmux            ###
#######################################

echo "### Install tmux ###"

if which dnf; then
    sudo dnf install -y tmux
elif which apt; then
    sudo apt install -y tmux
else
    echo "Missing `dnf` or `snap` package manager"
    exit 1
fi

ln -sf dev-env/tmux/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm # For the Dracula theme

#######################################
###         Install nvim            ###
#######################################

echo "### Install nvim"

if which dnf; then
    sudo dnf install -y neovim
elif which apt; then
    sudo apt install -y neovim
else
    echo "Missing `dnf` or `apt` package manager"
    exit 1
fi

sudo ln -sf /usr/bin/vi /usr/bin/nvim

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
