#!/usr/bin/env bash

# Update `flake.lock`. Also force-update karamel and fstar.
# We list the inputs to avoid updating nixpkgs too.
NIXPKGS="$(jq -r .nodes.nixpkgs.locked.rev flake.lock)"
nix flake update \
   charon aeneas eurydice bertie \
   --override-input charon "github:aeneasverif/charon" \
   --override-input aeneas "github:aeneasverif/aeneas" \
   --override-input eurydice "github:aeneasverif/eurydice" \
   --override-input eurydice/karamel "github:FStarLang/karamel" \
   --override-input bertie "github:cryspen/bertie"

./update-cargo-lock.sh bertie
