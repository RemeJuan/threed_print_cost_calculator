#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

IOS_DIR="fastlane/metadata/ios"
ANDROID_DIR="fastlane/metadata/android"

HAS_ERRORS=false

check_locale() {
  local dir=$1
  local locale=$2
  shift 2
  local files=("$@")
  local missing=0

  for f in "${files[@]}"; do
    local path="$dir/$locale/$f"
    if [ ! -f "$path" ]; then
      echo "MISSING: $path"
      HAS_ERRORS=true
      missing=$((missing + 1))
    elif grep -q "^TODO TRANSLATE:" "$path" 2>/dev/null; then
      echo "UNTRANSLATED: $path"
      HAS_ERRORS=true
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -eq 0 ]; then
    echo "  OK: $locale ($missing issues)"
  else
    echo "  ISSUES: $locale ($missing issues)"
  fi
}

echo "=== Validating iOS metadata ==="
for locale in en-US de-DE pt-BR es-ES fr-FR it ja; do
  check_locale "$IOS_DIR" "$locale" \
    name.txt subtitle.txt description.txt keywords.txt release_notes.txt support_url.txt
done

echo ""
echo "=== Validating Android metadata ==="
for locale in en-US de-DE pt-BR es-ES fr-FR it-IT ja-JP; do
  check_locale "$ANDROID_DIR" "$locale" \
    title.txt short_description.txt full_description.txt
done

echo ""
if [ "$HAS_ERRORS" = true ]; then
  echo "!! Issues found. Fix before pushing metadata."
  exit 1
else
  echo "All metadata files present and translated. Ready to push."
fi
