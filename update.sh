#!/usr/bin/env bash

HAX_BRANCH="${HAX_BRANCH:-main}"
EURYDICE_BRANCH="${EURYDICE_BRANCH:-main}"

# update `flake.lock`
nix flake update \
   --override-input hax "github:hacspec/hax?ref=$HAX_BRANCH" \
   --override-input eurydice "github:aeneasverif/eurydice?ref=$EURYDICE_BRANCH"

# update `STATUS.txt`
check () {
    STATUS=$(nix build -L --no-link .#packages.x86_64-linux."$1" && echo ✅ || echo ❌)
    echo "$STATUS $1 ($2)" >> STATUS.txt
}
rm -f STATUS.txt
check "hax" "$HAX_BRANCH"
check "eurydice" "$EURYDICE_BRANCH"

# commit changes
[[ $(git diff) != "" ]] || exit 0
git config --local user.name "Prosecco"
git config --local user.email "prosecco@inria.fr"
git commit -am "nightly update"
