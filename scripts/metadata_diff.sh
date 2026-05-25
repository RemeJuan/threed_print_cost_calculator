#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

MODE="${1:-all}"

show_diff() {
  local path=$1
  local label=$2
  echo "=== $label ==="
  if git diff -- "$path" | head -80; then
    :
  fi
  echo ""
}

case "$MODE" in
  ios)
    show_diff "fastlane/metadata/ios/" "iOS metadata diff"
    ;;
  android)
    show_diff "fastlane/metadata/android/" "Android metadata diff"
    ;;
  all)
    show_diff "fastlane/metadata/ios/" "iOS metadata diff"
    show_diff "fastlane/metadata/android/" "Android metadata diff"
    ;;
  *)
    echo "Usage: $0 [ios|android|all]"
    exit 1
    ;;
esac

echo "=== Untracked metadata files ==="
git ls-files --others --exclude-standard -- fastlane/metadata/ | head -20

echo ""
echo "Tip: Pipe this to a pager:  $0 ios | less"
