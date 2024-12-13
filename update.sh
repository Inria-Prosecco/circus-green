#!/usr/bin/env bash

# Update `flake.lock`
nix flake update

# Update the `Cargo.lock` file we keep for libcrux
LIBCRUX_COMMIT="$(nix shell nixpkgs#jq --command jq -r .nodes.libcrux.locked.rev flake.lock)"
git clone https://github.com/cryspen/libcrux
cd libcrux
git checkout "$LIBCRUX_COMMIT"
nix develop --command cargo generate-lockfile
cd ..
mv libcrux/Cargo.lock libcrux-Cargo.lock
rm -rf libcrux
