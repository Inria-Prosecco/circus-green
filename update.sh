#!/usr/bin/env bash

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
   --override-input libcrux "github:cryspen/libcrux?ref=$LIBCRUX_BRANCH" \
   --override-input bertie "github:cryspen/bertie?ref=$BERTIE_BRANCH"
