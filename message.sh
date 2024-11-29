#!/usr/bin/env bash

echo 'MSG<<EOF'
echo "*Nightly update*"
if [[ "$(jq 'map(.result == "success") | all' results.json)" == "true" ]]; then
    SUCCESS=1
    echo '✅✅✅'
else
    SUCCESS=0
    echo '❌❌❌'
fi
echo ""

echo "*Links:*"
COMMIT="$(git rev-parse HEAD)"
echo "commit: https://github.com/inria-prosecco/circus-green/commit/$COMMIT"
echo "run: https://github.com/inria-prosecco/circus-green/actions/runs/$RUN"
echo ""

echo "*Statuses:*"
for project in hax charon aeneas eurydice ml-kem bertie; do
    status="$(jq -r 'if .["'"$project"'"].result == "success" then "✅" else "❌" end' results.json)"
    echo "$status $project (main)"
done
echo ""

echo "*Tried to update:*"
git show origin/main:flake.lock > good.lock
cat flake.lock good.lock | jq -s -r '
    map( .nodes |
         [ .fstar, .karamel, .hax, .charon, .aeneas, .eurydice, .libcrux, .bertie ] |
         map( .locked )
    )
    | transpose
    | .[]
    | select(.[0].rev != .[1].rev)
    | "\(.[1].rev[0:8])..\(.[0].rev[0:8])" as $range
    | "\(.[0].repo): [\($range)](https://github.com/\(.[0].owner)/\(.[0].repo)/compare/\($range))"
    '
echo EOF

echo "SUCCESS=$SUCCESS"
