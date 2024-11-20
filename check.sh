#!/usr/bin/env bash
nix build -L --no-link ".#checks.$(uname -m)-linux.$1"
