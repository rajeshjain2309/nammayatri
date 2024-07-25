FROM gitpod/workspace-full

# Install Nix
RUN bash <(curl -L https://nixos.org/nix/install) --daemon

# Ensure Nix binary is available
ENV PATH=$PATH:/nix/var/nix/profiles/default/bin

# Install Cachix
RUN nix-env -iA cachix -f https://cachix.org/api/v1/install

# Use Cachix cache
RUN cachix use nammayatri

# Install home-manager and setup direnv and starship
RUN nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager && \
    nix-channel --update && \
    nix-shell '<home-manager>' -A install && \
    home-manager switch

RUN nix-env -iA nixpkgs.direnv nixpkgs.starship

# Install Haskell dependencies
RUN nix-env -iA nixpkgs.haskellPackages.cabal-install