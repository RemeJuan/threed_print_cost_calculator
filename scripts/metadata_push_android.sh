#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Dry-run: showing what will change..."
git diff --stat -- fastlane/metadata/android/

echo ""
echo "==> Pushing Android metadata to Google Play Console (beta track)..."
bundle exec fastlane android metadata_push track:beta

echo ""
echo "==> Android metadata uploaded to beta track."
echo "    Promote on Google Play Console if ready for production."
