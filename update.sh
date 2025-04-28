#!/usr/bin/env bash

# Update `flake.lock`. Also force-update karamel and fstar.
# We list the inputs to avoid updating nixpkgs too.
nix flake update \
   hax charon aeneas eurydice libcrux bertie \
   --override-input hax "github:hacspec/hax" \
   --override-input charon "github:aeneasverif/charon" \
   --override-input aeneas "github:aeneasverif/aeneas" \
   --override-input eurydice "github:aeneasverif/eurydice" \
   --override-input eurydice/karamel "github:FStarLang/karamel" \
   --override-input eurydice/karamel/fstar "github:FStarLang/fstar" \
   --override-input libcrux "github:cryspen/libcrux" \
   --override-input bertie "github:cryspen/bertie"

./update-cargo-lock.sh libcrux
./update-cargo-lock.sh bertie
