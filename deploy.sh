#!/bin/sh

set -e

git remote set-url origin "https://user:$GH_TOKEN@github.com/$TRAVIS_REPO_SLUG.git"
npm set //registry.npmjs.org/:_authToken "$NPM_TOKEN"

git fetch origin "$TRAVIS_BRANCH":"$TRAVIS_BRANCH"
git checkout master

PKG_VERSION=$(jq -r '.version' src/package.json)

git fetch origin v"$PKG_VERSION" || {
  yarn global add standard-version
  standard-version -a --release-as "$PKG_VERSION"
  tmp=$(mktemp)
  jq '.version = "0.0.0"' package.json> "$tmp" && \mv "$tmp" package.json
  git commit --amend --no-edit
  git push --follow-tags origin master
  npm publish dist --access=public
}
