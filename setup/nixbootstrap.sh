#!/bin/bash

if [ -d "/nix" ]; then
    echo "/nix found, aborting install"
else
    echo "Installing Nix..."
    # Nix install requires curl and rsync, this should be taken
    # care of in the bootstrap script
    sh <(curl -L https://nixos.org/nix/install)
    source ${HOME}/.nix-profile/etc/profile.d/nix.sh
fi

nixapps="nixpkgs.exa nixpkgs.bat nixpkgs.gping nixpkgs.gtop"
nix-env -iA ${nixapps}
