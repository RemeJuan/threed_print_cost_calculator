# Patrol CI and Firebase Test Lab

This repository's Android E2E release gate is the bundled Patrol suite in `patrol_test/`.

Current gate journeys:

1. `free_core_calculation_journey_test.dart`
2. `premium_calculate_save_history_journey_test.dart`

## Local validation

Use the bundled suite on the Android emulator:

```bash
PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall
```

`--no-uninstall` is useful for local emulator stability. CI and Firebase Test Lab use the built artifacts instead.

## Build Android Patrol artifacts

```bash
./scripts/prepare_patrol_android_artifacts.sh
```

This produces:

- `build/patrol_artifacts/android/app-debug.apk`
- `build/patrol_artifacts/android/app-debug-androidTest.apk`

## Run on Firebase Test Lab

```bash
./scripts/run_patrol_android_ftl.sh
```

Default matrix:

- model: `MediumPhone.arm`
- Android API: `35`
- locale: `en`
- orientation: `portrait`

Supported environment overrides:

- `PATROL_ANDROID_APP_APK`
- `PATROL_ANDROID_TEST_APK`
- `FIREBASE_TEST_LAB_DEVICE_MODEL`
- `FIREBASE_TEST_LAB_DEVICE_VERSION`
- `FIREBASE_TEST_LAB_DEVICE_LOCALE`
- `FIREBASE_TEST_LAB_DEVICE_ORIENTATION`
- `FIREBASE_TEST_LAB_TIMEOUT`
- `FIREBASE_TEST_LAB_RESULTS_HISTORY_NAME`
- `FIREBASE_TEST_LAB_RESULTS_DIR_PREFIX`
- `FIREBASE_TEST_LAB_RESULTS_BUCKET`

The Firebase run uses a single bundled instrumentation build, so both Patrol journeys execute inside one suite-style test matrix instead of one build per journey.

## Codemagic

`codemagic.yaml` defines workflow `patrol_e2e_android`, which:

1. installs Flutter tooling and Patrol CLI
2. runs `fvm flutter analyze`
3. runs lower-level tests with `fvm flutter test test`
4. builds the bundled Patrol Android artifacts
5. runs that suite on Firebase Test Lab
6. publishes APKs and native test reports as build artifacts

Required Codemagic secret group: `firebase_test_lab`

- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`: service account JSON contents
