# Testing

## Test Pyramid

- Unit tests: primary logic coverage.
- Widget tests: UI and state wiring coverage.
- Patrol: 2 release-gate E2E journeys only.

## Patrol Journeys

1. `Free Core Calculation Journey`
   - Protects the free-user flow from settings through calculator output.
   - Exists to prove the core product path still works in the real app shell.

2. `Premium Calculate, Save, and Verify History Journey`
   - Protects the premium gated calculator flow, save action, persistence, and history rendering.
   - Exists because it covers the highest-value premium app-owned path in one journey.

Only these 2 Patrol journeys remain because lower-level tests now cover the rest of the old integration surface well enough, and device-farm time should stay focused on distinct release risks.

## Run Locally

```bash
fvm flutter test test
```

```bash
PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall
```

Optional legacy integration checks:

```bash
fvm flutter test integration_test
```

## Setup

- Use `fvm` with the repo's Flutter version.
- For Patrol, install the Patrol CLI and have an Android emulator available, or use the Firebase Test Lab scripts.
- The Patrol harness expects the Android app to be buildable locally; `PATROL_FLUTTER_COMMAND="fvm flutter"` keeps Patrol aligned with the repo toolchain.

## CI Overview

- Patrol is the E2E gate.
- Unit and widget tests run as fast lower-level checks.
- Firebase Test Lab runs the bundled Patrol suite.
