#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Pulling metadata from iOS App Store Connect..."
bundle exec fastlane ios metadata_pull

echo ""
echo "==> Pulling metadata from Google Play Console (no-op - supply has no download)..."
bundle exec fastlane android metadata_pull

echo ""
echo "==> Done. iOS metadata written to fastlane/metadata/ios/"
echo "    Android: export manually from Google Play Console > Manage > Store listing."
echo "    Review with 'git diff' before committing."
