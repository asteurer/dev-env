#!/bin/bash

#######################################
###       Install dnf packages      ###
#######################################

sudo dnf -y upgrade
sudo dnf -y install \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    tmux \
    neovim \
    wget \
    btop

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

# Install theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# Symlink config files
ln -sf $(realpath ../shared/.p10k.zsh) ~/.p10k.zsh
ln -sf $(realpath ../shared/.zshrc) ~/.zshrc

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
###          Install Go             ###
#######################################
go_version=$(curl -s https://go.dev/VERSION?m=text | head -n 1 | tr -d '\n')
go_os_arch="linux-amd64"

sudo rm -rf /usr/local/go

wget -q "https://go.dev/dl/${go_version}.${go_os_arch}.tar.gz"
sudo tar -C /usr/local -xzf "${go_version}.${go_os_arch}.tar.gz"
rm "${go_version}.${go_os_arch}.tar.gz"

#######################################
###     Install Spin + friends      ###
#######################################

# Spin
mkdir spin && cd spin
curl -fsSL https://spinframework.dev/downloads/install.sh | bash
sudo mv spin /usr/local/bin/
cd .. && rm -rf spin

spin plugins update
spin plugins install -y otel
spin plugins install -y verman

# For compiling Spin
sudo dnf install -y \
    openssl-devel \
    c++
~/.cargo/bin/rustup target add wasm32-wasip1
~/.cargo/bin/rustup target add wasm32-wasip2

# TinyGo
tinygo_version=0.38.0
wget https://github.com/tinygo-org/tinygo/releases/download/v$tinygo_version/tinygo$tinygo_version.linux-amd64.tar.gz
tar -xf tinygo$tinygo_version.linux-amd64.tar.gz
sudo mv tinygo ~
rm tinygo$tinygo_version.linux-amd64.tar.gz

# Wasmtime
curl https://wasmtime.dev/install.sh -sSf | bash

# wasm-tools
~/.cargo/bin/cargo install wasm-tools

# wkg
~/.cargo/bin/cargo install wkg

#######################################
###         Configure tmux          ###
#######################################

ln -sf $(realpath ../shared/.tmux.conf) ~/.tmux.conf

# Download and install plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins all

#######################################
###         Configure nvim          ###
#######################################

sudo ln -sf /usr/bin/nvim /usr/bin/vi

#######################################
###         Configure git           ###
#######################################

ln -sf $(realpath ../shared/.gitconfig) ~/.gitconfig
