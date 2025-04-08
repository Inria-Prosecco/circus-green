#!/usr/bin/env bash

# Update `flake.lock`. `nix flake update` doesn't suffice because that won't
# force-update nested dependencies like karamel.
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

# Generates a `Cargo.lock` for the given project.
function generate_cargo_lock() {
   PROJECT="$1"
   COMMIT="$(jq -r .nodes."$PROJECT".locked.rev flake.lock)"
   OWNER="$(jq -r .nodes."$PROJECT".locked.owner flake.lock)"
   REPO="$(jq -r .nodes."$PROJECT".locked.repo flake.lock)"
   git clone "https://github.com/$OWNER/$REPO" tmp
   cd tmp
   git checkout "$COMMIT"
   cargo generate-lockfile
   cd ..
   mv tmp/Cargo.lock "$PROJECT"-Cargo.lock
   rm -rf tmp
}

generate_cargo_lock libcrux
generate_cargo_lock bertie
