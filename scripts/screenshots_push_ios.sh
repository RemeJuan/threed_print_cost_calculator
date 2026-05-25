#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

echo "==> Pushing iOS screenshots to App Store Connect..."
bundle exec fastlane ios screenshot_push

echo ""
echo "==> iOS screenshots uploaded."
