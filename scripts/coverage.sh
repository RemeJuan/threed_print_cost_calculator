#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW_COVERAGE="$ROOT_DIR/coverage/lcov.info"

cd "$ROOT_DIR"

if ! command -v lcov >/dev/null 2>&1; then
  printf 'lcov is required to filter coverage output.\n' >&2
  exit 1
fi

fvm flutter test --coverage --no-pub --test-randomize-ordering-seed random

exclude_files=()

add_exclude_if_traced() {
  local file="$1"
  if grep -Fqx "SF:$file" "$RAW_COVERAGE"; then
    exclude_files+=("$file")
  fi
}

if [ -d "$ROOT_DIR/lib/generated" ]; then
  while IFS= read -r file; do
    add_exclude_if_traced "$file"
  done < <(rg --files lib/generated)
fi

while IFS= read -r file; do
  add_exclude_if_traced "$file"
done < <(
  rg --files lib \
    -g '*.g.dart' \
    -g '*.freezed.dart'
)

for file in lib/firebase_options.dart lib/bootstrap.dart; do
  if [ -f "$ROOT_DIR/$file" ]; then
    add_exclude_if_traced "$file"
  fi
done

if [ ${#exclude_files[@]} -eq 0 ]; then
  lcov --summary "$RAW_COVERAGE"
  exit 0
fi

lcov \
  --remove "$RAW_COVERAGE" \
  "${exclude_files[@]}" \
  -o "$RAW_COVERAGE"

lcov --summary "$RAW_COVERAGE"
