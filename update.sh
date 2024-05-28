#!/usr/bin/env bash

HAX_BRANCH="${HAX_BRANCH:-main}"
CHARON_BRANCH="${CHARON_BRANCH:-main}"
EURYDICE_BRANCH="${EURYDICE_BRANCH:-main}"
LIBCRUX_BRANCH="${LIBCRUX_BRANCH:-dev}"

# update `flake.lock`
nix flake update \
   --override-input hax "github:hacspec/hax?ref=$HAX_BRANCH" \
   --override-input charon "github:aeneasverif/charon?ref=$CHARON_BRANCH" \
   --override-input eurydice "github:aeneasverif/eurydice?ref=$EURYDICE_BRANCH" \
   --override-input libcrux "github:cryspen/libcrux?ref=$LIBCRUX_BRANCH"

# update `STATUS.txt`
check () {
    STATUS=$(nix build -L --no-link .#packages.x86_64-linux."$1" && echo ✅ || echo ❌)
    echo "$STATUS $1 ($2)" >> STATUS.txt
}
rm -f STATUS.txt
check "hax" "$HAX_BRANCH"
check "charon" "$CHARON_BRANCH"
check "eurydice" "$EURYDICE_BRANCH"
check "ml-kem" "$LIBCRUX_BRANCH"

# commit changes
[[ $(git diff) != "" ]] || exit 0
git config --local user.name "Prosecco"
git config --local user.email "prosecco@inria.fr"
git commit -am "nightly update"
