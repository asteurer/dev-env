#!/bin/bash

###########################
###  Run shared scripts ###
###########################
./../shared/shared_setup.sh

###############################
### Addtl config for .zshrc ###
###############################
# Create a copy of the .zshrc.template file
cp ../shared/.zshrc.template ../shared/.zshrc
