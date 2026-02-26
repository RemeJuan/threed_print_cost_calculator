#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
DATE_STR="$(date +%F)"
BRANCH="chore/biweekly-maintenance-${DATE_STR}"

mkdir -p .codex-cache/pub
export PUB_CACHE="$REPO_ROOT/.codex-cache/pub"

# Preflight network
git ls-remote https://github.com/flutter/flutter.git HEAD >/dev/null
git fetch origin

# Create/update branch from origin/<default> (worktree-safe)
if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  git checkout "$BRANCH"
  git reset --hard "origin/$DEFAULT_BRANCH"
else
  git checkout -b "$BRANCH" "origin/$DEFAULT_BRANCH"
fi

echo "=== Toolchain gate (outside Codex) ==="
fvm flutter --version
fvm flutter doctor -v

echo "=== Baseline ==="
fvm flutter pub get
fvm dart analyze
fvm flutter test

echo "=== Upgrade deps ==="
fvm flutter pub upgrade
fvm flutter pub outdated || true

echo "=== Verify ==="
fvm dart analyze
fvm flutter test

echo "=== Commit maintenance ==="
git add -A
git commit -m "chore: biweekly maintenance (${DATE_STR})"

echo "=== Version bump (amend) ==="
make bump_fix

echo "=== Final verification ==="
fvm dart analyze
fvm flutter test

echo "=== Push branch ==="
git push -u origin "$BRANCH"

# Optional: open PR if gh CLI is installed and authenticated
if command -v gh >/dev/null 2>&1; then
  gh pr create \
    --base "$DEFAULT_BRANCH" \
    --head "$BRANCH" \
    --title "chore: biweekly maintenance (${DATE_STR})" \
    --body "Summary:
- Dependency upgrades applied (see commits).
- Version bumped via make bump_fix (amended commit).
- Checks: dart analyze + flutter test."
else
  echo "gh CLI not found; create PR manually for branch: $BRANCH"
fi

echo "Done. Branch: $BRANCH"