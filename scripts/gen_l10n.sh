#!/bin/bash

# Exit with nonzero exit code if anything fails and show script content
# set -ex

# Get repository top level folder
pushd "$(git rev-parse --show-toplevel)"

flutter gen-l10n \
    --template-arb-file=intl_en.arb \
    --output-localization-file=app_localizations.dart \
    --output-class=AppLocalizations

popd
echo "Finished generating localizations."
