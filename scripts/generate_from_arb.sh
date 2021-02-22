#!/bin/bash

# Exit with nonzero exit code if anything fails and show script content
# set -ex

# Get repository top level folder
pushd "$(git rev-parse --show-toplevel)"

flutter pub run intl_translation:generate_from_arb \
    --output-dir=lib/l10n \
    --no-use-deferred-loading \
    lib/app_localizations.dart lib/l10n/intl_*.arb

popd
echo "Finished generating translations from arb."
