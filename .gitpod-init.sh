#!/bin/bash

# Set up Nix binary cache
nix run nixpkgs#cachix use nammayatri

# Add yourself to the trusted-users list of nix.conf
echo "trusted-users = root gitpod" | sudo tee -a /etc/nix/nix.conf

# Restart the Nix daemon
sudo pkill nix-daemon

# Ensure Nix health
nix run nixpkgs#nix-health github:nammayatri/nammayatri
