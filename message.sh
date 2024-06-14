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
echo "*Tried to update:*"
cat flake.lock good.lock | jq -s -r '
    map( .nodes |
         [ .nixpkgs, .fstar, .karamel, .hax, .charon, .eurydice, .libcrux, .bertie ] |
         map( .locked )
    ) | transpose | map(select(.[0].rev != .[1].rev)) | .[] |
    (.[0].repo + ": [" + .[0].rev[0:8] + ".." + .[1].rev[0:8] + "](https://github.com/" + .[0].owner + "/" + .[0].repo + "/compare/" + .[0].rev[0:8] + "..." + .[1].rev[0:8] + ")")
    '
