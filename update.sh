#!/usr/bin/env bash

HAX_BRANCH="${HAX_BRANCH:-main}"
CHARON_BRANCH="${CHARON_BRANCH:-main}"
EURYDICE_BRANCH="${EURYDICE_BRANCH:-main}"
LIBCRUX_BRANCH="${LIBCRUX_BRANCH:-dev}"
BERTIE_BRANCH="${BERTE_BRANCH:-main}"

# update `flake.lock`
nix flake update \
   --override-input hax "github:hacspec/hax?ref=$HAX_BRANCH" \
   --override-input charon "github:aeneasverif/charon?ref=$CHARON_BRANCH" \
   --override-input eurydice "github:aeneasverif/eurydice?ref=$EURYDICE_BRANCH" \
   --override-input libcrux "github:cryspen/libcrux?ref=$LIBCRUX_BRANCH" \
   --override-input bertie "github:cryspen/bertie?ref=$BERTIE_BRANCH"

# update `STATUS.txt`
check () {
    echo "##[group]$1"
    STATUS=$(nix build -L --no-link .#packages.x86_64-linux."$1" && echo ✅ || echo ❌)
    echo "##[endgroup]"
    echo "$STATUS $1 ($2)" >> STATUS.txt
}
rm -f STATUS.txt
check "hax" "$HAX_BRANCH"
check "charon" "$CHARON_BRANCH"
check "eurydice" "$EURYDICE_BRANCH"
check "ml-kem" "$LIBCRUX_BRANCH"
check "bertie" "$BERTIE_BRANCH"
