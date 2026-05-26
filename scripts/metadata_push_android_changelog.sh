#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

TRACK="${1:-${TRACK:-${METADATA_TRACK:-open_testing}}}"
TRACK_NORMALIZED="$(printf '%s' "$TRACK" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' )"
if [[ "$TRACK_NORMALIZED" == "open_testing" || "$TRACK_NORMALIZED" == "open-testing" || "$TRACK_NORMALIZED" == "open_testing" ]]; then
  TRACK="beta"
fi

echo "==> Changelog diff (files to be pushed):"
git diff --stat -- 'fastlane/metadata/android/*/changelogs/default.txt'

echo ""
echo "==> Pushing Android changelogs to Google Play Console (${TRACK} track)..."
bundle exec fastlane android changelog_push track:"${TRACK}"

echo ""
echo "==> Android changelogs uploaded."
echo "    Listing title/short/full description and screenshots were not pushed."
