#!/bin/bash

# Exit with nonzero exit code if anything fails and show script content
# set -ex

# Get repository top level folder
pushd "$(git rev-parse --show-toplevel)"

flutter pub run intl_translation:extract_to_arb \
    --output-dir=lib/l10n \
    --output-file=intl_en.arb \
    --suppress-last-modified \
    lib/app_localizations.dart

popd
echo "Finished generating translations to arb."
