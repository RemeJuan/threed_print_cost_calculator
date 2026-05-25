#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Pushing Android screenshots to Google Play Console..."
bundle exec fastlane android screenshot_push

echo ""
echo "==> Android screenshots uploaded."
