#!/bin/bash

# Exit with nonzero exit code if anything fails and show script content
# set -ex

# Get repository top level folder
pushd "$(git rev-parse --show-toplevel)"
export LATEST_TAG="$(git describe --tags --abbrev=0)"
export CURRENT_BRANCH="$(git branch --show-current)"

git pull
git push origin :refs/tags/$LATEST_TAG
git tag -fa $LATEST_TAG -m $LATEST_TAG
git push origin $CURRENT_BRANCH --tags

popd
echo "Finished advancing latest tag."
