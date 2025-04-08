#!/usr/bin/env bash
# The override is a temporary hack while https://github.com/FStarLang/FStar/pull/3836 gets merged.
nix build -L --no-link ".#checks.$(uname -m)-linux.$1" \
    --override-input eurydice/karamel/fstar/nixpkgs "nixpkgs/88efe689298b1863db0310c0a22b3ebb4d04fbc3" \
