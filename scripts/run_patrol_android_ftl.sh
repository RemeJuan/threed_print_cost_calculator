#!/bin/zsh

set -euo pipefail

app_apk="${PATROL_ANDROID_APP_APK:-build/patrol_artifacts/android/app-debug.apk}"
test_apk="${PATROL_ANDROID_TEST_APK:-build/patrol_artifacts/android/app-debug-androidTest.apk}"
device_model="${FIREBASE_TEST_LAB_DEVICE_MODEL:-MediumPhone.arm}"
device_version="${FIREBASE_TEST_LAB_DEVICE_VERSION:-35}"
device_locale="${FIREBASE_TEST_LAB_DEVICE_LOCALE:-en}"
device_orientation="${FIREBASE_TEST_LAB_DEVICE_ORIENTATION:-portrait}"
timeout_value="${FIREBASE_TEST_LAB_TIMEOUT:-15m}"
results_history_name="${FIREBASE_TEST_LAB_RESULTS_HISTORY_NAME:-Patrol E2E}"
results_dir_prefix="${FIREBASE_TEST_LAB_RESULTS_DIR_PREFIX:-patrol-e2e}"
results_dir="${results_dir_prefix}/$(date +%Y%m%d-%H%M%S)"

if [[ ! -f "$app_apk" ]]; then
  printf 'Missing app APK: %s\n' "$app_apk" >&2
  exit 1
fi

if [[ ! -f "$test_apk" ]]; then
  printf 'Missing test APK: %s\n' "$test_apk" >&2
  exit 1
fi

command=(
  gcloud firebase test android run
  --type instrumentation
  --app "$app_apk"
  --test "$test_apk"
  --device "model=${device_model},version=${device_version},locale=${device_locale},orientation=${device_orientation}"
  --use-orchestrator
  --timeout "$timeout_value"
  --results-history-name "$results_history_name"
  --results-dir "$results_dir"
  --client-details "matrixLabel=Patrol suite,suite=patrol-e2e"
)

if [[ -n "${FIREBASE_TEST_LAB_RESULTS_BUCKET:-}" ]]; then
  command+=(--results-bucket "$FIREBASE_TEST_LAB_RESULTS_BUCKET")
fi

printf 'Running Patrol suite on Firebase Test Lab\n'
printf '%s\n' \
  "- app: $app_apk" \
  "- test: $test_apk" \
  "- device: ${device_model} / API ${device_version} / ${device_locale} / ${device_orientation}" \
  "- results-dir: $results_dir"

"${command[@]}"
