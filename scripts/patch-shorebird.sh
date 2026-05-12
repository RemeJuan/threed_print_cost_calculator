#!/usr/bin/env bash
set -euo pipefail

echo “Checking required tools…”
command -v shorebird >/dev/null 2>&1 || { echo “shorebird CLI not found”; exit 1; }
command -v flutter >/dev/null 2>&1 || { echo “flutter not found”; exit 1; }

echo “Checking working tree…”
if ! git diff --quiet || ! git diff --cached --quiet; then
echo “Uncommitted changes found. Commit/stash before patching.”
exit 1
fi

echo “Running sanity checks…”
fvm flutter analyze
fvm flutter test

echo “Creating Shorebird Android patch…”
shorebird patch android

echo “Creating Shorebird iOS patch…”
shorebird patch ios

echo “Done. Android and iOS Shorebird patches created.”
#!/usr/bin/env bash
set -euo pipefail

get_latest_release_version() {
  local platform="$1"

  shorebird releases list "$platform" \
    | awk '/^[0-9]+\.[0-9]+\.[0-9]+/ { print $1; exit }'
}

patch_platform() {
  local platform="$1"
  local release_version

  echo "Finding latest Shorebird ${platform} release..."
  release_version="$(get_latest_release_version "$platform")"

  if [[ -z "$release_version" ]]; then
    echo "Could not determine latest Shorebird ${platform} release."
    exit 1
  fi

  echo "Creating Shorebird ${platform} patch for release ${release_version}..."
  shorebird patch "$platform" --release-version "$release_version"
}

echo "Checking required tools..."
command -v shorebird >/dev/null 2>&1 || { echo "shorebird CLI not found"; exit 1; }
command -v fvm >/dev/null 2>&1 || { echo "fvm not found"; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "awk not found"; exit 1; }

echo "Checking working tree..."
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Uncommitted changes found. Commit/stash before patching."
  exit 1
fi

echo "Running sanity checks..."
fvm flutter analyze
fvm flutter test

patch_platform android
patch_platform ios

echo "Done. Android and iOS Shorebird patches created."