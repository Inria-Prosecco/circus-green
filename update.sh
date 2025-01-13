#!/usr/bin/env bash

# Update `flake.lock`. `nix flake update` doesn't suffice because that won't
# force-update nested dependencies like karamel.
nix flake update \
   --override-input hax "github:hacspec/hax" \
   --override-input charon "github:aeneasverif/charon" \
   --override-input aeneas "github:aeneasverif/aeneas" \
   --override-input eurydice "github:aeneasverif/eurydice" \
   --override-input karamel "github:FStarLang/karamel" \
   --override-input karamel/fstar "github:FStarLang/fstar" \
   --override-input libcrux "github:cryspen/libcrux" \
   --override-input bertie "github:cryspen/bertie"

# Update the `Cargo.lock` file we keep for libcrux
LIBCRUX_COMMIT="$(nix shell nixpkgs#jq --command jq -r .nodes.libcrux.locked.rev flake.lock)"
git clone https://github.com/cryspen/libcrux
cd libcrux
git checkout "$LIBCRUX_COMMIT"
nix develop --command cargo generate-lockfile
cd ..
mv libcrux/Cargo.lock libcrux-Cargo.lock
rm -rf libcrux
