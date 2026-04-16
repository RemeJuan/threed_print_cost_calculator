# Workflows

## Common commands

- Setup: `fvm flutter pub get`
- Format: `fvm dart format .`
- Analyze: `fvm flutter analyze`
- Unit/widget tests: `make flutter_test`
- Single test file: `fvm flutter test path/to_test.dart`
- Codegen: `make flutter_generate`
- Local coverage: `./scripts/coverage.sh`

## Verify order

- Default: `fvm flutter analyze` then `make flutter_test`.
- If generated code or localization changed, run `make flutter_generate` first.
- If app shell or premium/history flows changed, run the relevant `integration_test/` or Patrol journey.

## Release/versioning

- Version bumps use Makefile helpers: `make bump_fix`, `make bump_feat`, `make bump_build`.
- `CHANGELOG.md` is user-facing; only include changes with user impact.
- Keep changelog entries at the top and use the existing `Added`, `Changed`, `Fixed` structure.

## E2E

- Patrol is the release gate.
- Local run: `PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall`.
- Android Patrol artifact and Firebase Test Lab flow is documented in `docs/patrol_ci.md`.
