#!/usr/bin/env bash

cat STATUS.txt | grep '❌' > /dev/null && echo '❌❌❌' || echo '✅✅✅'
echo ""
echo "*Links:*"
echo "commit: https://github.com/inria-prosecco/circus-green/commit/$(git show-ref --hash refs/heads/main)"
echo "run: https://github.com/inria-prosecco/circus-green/actions/runs/$RUN"
echo ""
echo "*Statuses:*"
cat STATUS.txt
echo ""
echo "*Locked dependencies:*"
cat flake.lock | jq -r '
    .nodes |
    .[ "nixpkgs", "fstar", "karamel", "hax", "charon", "eurydice", "libcrux", "bertie" ] |
    .locked |
    .repo + ": https://github.com/" + .owner + "/" + .repo + "/commit/" + .rev
    '
