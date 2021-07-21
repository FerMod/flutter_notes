#!/bin/bash

# Exit with nonzero exit code if anything fails and show script content
# set -ex

git tag -a $1 $2^{}
git tag -d $2
git push origin $1 :$2

popd
echo "Finished renaming tag."
