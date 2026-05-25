#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Dry-run: showing what will change..."
git diff --stat -- fastlane/metadata/ios/

echo ""
echo "==> Pushing iOS metadata to App Store Connect..."
bundle exec fastlane ios metadata_push

echo ""
echo "==> iOS metadata uploaded."
echo "    Changes are live on App Store Connect (not yet submitted for review)."
