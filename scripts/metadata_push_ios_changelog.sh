#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Release notes diff (files to be pushed):"
git --no-pager diff --stat -- 'fastlane/metadata/ios/*/release_notes.txt'

echo ""
echo "==> Pushing iOS release notes to App Store Connect..."
CI=1 EDITOR=true VISUAL=true GIT_EDITOR=true bundle exec fastlane ios release_notes_push

echo ""
echo "==> iOS release notes uploaded."
echo "    Description, subtitle, keywords, and other metadata were not pushed."
