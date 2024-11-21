#!/usr/bin/env bash

FSTAR_BRANCH="${FSTAR_BRANCH:-master}"
KARAMEL_BRANCH="${KARAMEL_BRANCH:-master}"
HAX_BRANCH="${HAX_BRANCH:-main}"
CHARON_BRANCH="${CHARON_BRANCH:-main}"
EURYDICE_BRANCH="${EURYDICE_BRANCH:-main}"
LIBCRUX_BRANCH="${LIBCRUX_BRANCH:-main}"
BERTIE_BRANCH="${BERTE_BRANCH:-main}"

# Update `flake.lock`
nix flake update \
   --override-input hax "github:hacspec/hax?ref=$HAX_BRANCH" \
   --override-input charon "github:aeneasverif/charon?ref=$CHARON_BRANCH" \
   --override-input eurydice "github:aeneasverif/eurydice?ref=$EURYDICE_BRANCH" \
   --override-input eurydice/karamel "github:FStarLang/karamel?ref=$KARAMEL_BRANCH" \
   --override-input eurydice/karamel/fstar "github:FStarLang/fstar?ref=$FSTAR_BRANCH" \
   --override-input libcrux "github:cryspen/libcrux?ref=$LIBCRUX_BRANCH" \
   --override-input bertie "github:cryspen/bertie?ref=$BERTIE_BRANCH"

# Update the `Cargo.lock` file we keep for libcrux
LIBCRUX_COMMIT="$(nix shell nixpkgs#jq --command jq -r .nodes.libcrux.locked.rev flake.lock)"
git clone https://github.com/cryspen/libcrux
cd libcrux
git checkout "$LIBCRUX_COMMIT"
nix develop --command cargo generate-lockfile
cd ..
mv libcrux/Cargo.lock libcrux-Cargo.lock
rm -rf libcrux
