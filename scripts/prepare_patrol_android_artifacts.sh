#!/bin/zsh

set -euo pipefail

export PATH="$PATH:$HOME/.pub-cache/bin"
export PATROL_FLUTTER_COMMAND="${PATROL_FLUTTER_COMMAND:-fvm flutter}"

app_apk="build/app/outputs/apk/debug/app-debug.apk"
test_apk="build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
artifacts_dir="build/patrol_artifacts/android"

fvm flutter pub get
patrol build android

mkdir -p "$artifacts_dir"
cp "$app_apk" "$artifacts_dir/app-debug.apk"
cp "$test_apk" "$artifacts_dir/app-debug-androidTest.apk"

printf 'Prepared Patrol Android artifacts:\n'
printf '%s\n' "- $artifacts_dir/app-debug.apk" "- $artifacts_dir/app-debug-androidTest.apk"
