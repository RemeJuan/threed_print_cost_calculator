#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

IOS_DIR="fastlane/metadata/ios"
ANDROID_DIR="fastlane/metadata/android"

HAS_ERRORS=false

char_count() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
print(len(path.read_text(encoding="utf-8")))
PY
}

check_max_length() {
  local path=$1
  local max=$2

  if [ ! -f "$path" ]; then
    return
  fi

  local count
  count=$(char_count "$path")
  if [ "$count" -gt "$max" ]; then
    echo "TOO LONG: $path ($count chars, max $max)"
    HAS_ERRORS=true
  fi
}

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
for locale in en-GB de-DE pt-BR es-ES fr-FR it ja; do
  check_locale "$IOS_DIR" "$locale" \
    name.txt subtitle.txt description.txt keywords.txt release_notes.txt

  check_max_length "$IOS_DIR/$locale/name.txt" 30
  check_max_length "$IOS_DIR/$locale/subtitle.txt" 30
  check_max_length "$IOS_DIR/$locale/keywords.txt" 100
  check_max_length "$IOS_DIR/$locale/description.txt" 4000
  check_max_length "$IOS_DIR/$locale/release_notes.txt" 4000
done

echo ""
echo "=== Validating Android metadata ==="
for locale in en-GB de-DE pt-BR es-ES fr-FR it-IT ja-JP; do
  check_locale "$ANDROID_DIR" "$locale" \
    title.txt short_description.txt full_description.txt changelogs/default.txt

  check_max_length "$ANDROID_DIR/$locale/title.txt" 50
  check_max_length "$ANDROID_DIR/$locale/short_description.txt" 80
  check_max_length "$ANDROID_DIR/$locale/full_description.txt" 4000
  check_max_length "$ANDROID_DIR/$locale/changelogs/default.txt" 500
done

echo ""
if [ "$HAS_ERRORS" = true ]; then
  echo "!! Issues found. Fix before pushing metadata."
  exit 1
else
  echo "All metadata files present, translated, and within length limits. Ready to push."
fi
