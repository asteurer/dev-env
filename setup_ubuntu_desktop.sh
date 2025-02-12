#!/bin/bash

#######################################
###   Install DisplayLink Drivers   ###
#######################################
wget https://www.synaptics.com/sites/default/files/Ubuntu/pool/stable/main/all/synaptics-repository-keyring.deb
sudo apt install ./synaptics-repository-keyring.deb
sudo apt update
sudo apt install -y displaylink-driver

#######################################
###         Install Neovim          ###
#######################################

# For some reason, neovim's stable version is not the latest version,
# so we have to use the unstable apt repository
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install -y neovim
sudo ln -sf /usr/bin/nvim /usr/bin/vi

# Install various packages
sudo apt install -y git
git config --global user.email "andrew.steurer@cognizant.com"
git config --global user.name "Andrew Steurer"

sudo snap install code


# Install Dracula theme
sudo apt install dconf-cli
git clone https://github.com/dracula/gnome-terminal dracula-setup
cd dracula-setup
./install.sh
cd ..

# TODO: You will need to configure your gnome-shell profile to use the nerd font
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
unzip FiraCode.zip
rm FiraCode.zip
fc-cache -fv

# Install the Cloudflare WARP package
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
sudo apt update && sudo apt install -y cloudflare-warp

# Cleanup
rm synaptics-repository-keyring.deb
rm -rf dracula-setup