#!/usr/bin/env bash

HAX_BRANCH="${HAX_BRANCH:-main}"
CHARON_BRANCH="${CHARON_BRANCH:-main}"

# update `flake.lock`
nix flake update \
   --override-input hax "github:hacspec/hax?ref=$HAX_BRANCH" \
   --override-input charon "github:aeneasverif/charon?ref=$CHARON_BRANCH"

# update `charon.lock`
HAX_REV=$(nix eval --raw .#inputs.hax.rev)
cp -r $(nix eval --raw .#inputs.charon) charon
chmod -R +w charon
cd charon/charon
nix run nixpkgs#cargo -- update -p hax-frontend-exporter --precise $HAX_REV
nix run nixpkgs#cargo -- update -p hax-frontend-exporter-options --precise $HAX_REV
cd ../..
cp charon/charon/Cargo.lock charon.lock
rm -rf charon

# update `STATUS.txt`
check () {
    STATUS=$(nix build -L --no-link .#packages.x86_64-linux."$1" && echo ✅ || echo ❌)
    echo "$STATUS $1 ($2)" >> STATUS.txt
}
rm -f STATUS.txt
check "hax" "$HAX_BRANCH"
check "charon" "$CHARON_BRANCH"

# commit changes
[[ $(git diff) != "" ]] || exit 0
git config --local user.name "Prosecco"
git config --local user.email "prosecco@inria.fr"
git commit -am "nightly update"
