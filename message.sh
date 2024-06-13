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
echo "\`\`\`txt"
cat good.lock flake.lock | jq -s -r '
    def link: "[" + .rev + "](https://github.com/" + .owner + "/" + .repo + "/commit/" + .rev + ")";
    map( .nodes |
         [ .nixpkgs, .fstar, .karamel, .hax, .charon, .eurydice, .libcrux, .bertie ] |
         map( .locked )
    ) | transpose | .[] |
    (.[0].repo + ": " + (.[0] | link) + " -> " + (.[1] | link) + " (" + .[0].repo + ")")
    '
echo "\`\`\`"
