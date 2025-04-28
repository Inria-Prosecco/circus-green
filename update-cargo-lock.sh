#!/usr/bin/env bash
# Updates/generates a `Cargo.lock` for the given project.
PROJECT="$1"
COMMIT="$(jq -r .nodes."$PROJECT".locked.rev flake.lock)"
OWNER="$(jq -r .nodes."$PROJECT".locked.owner flake.lock)"
REPO="$(jq -r .nodes."$PROJECT".locked.repo flake.lock)"
git clone "https://github.com/$OWNER/$REPO" tmp
cp "$PROJECT"-Cargo.lock tmp/Cargo.lock
cd tmp
git checkout "$COMMIT"
# Ensure the lockfile is up-to-date without updating deps unnecessarily
cargo metadata > /dev/null
cd ..
mv tmp/Cargo.lock "$PROJECT"-Cargo.lock
rm -rf tmp
