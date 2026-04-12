# threed_print_cost_calculator

## Commands
- Setup: `fvm flutter pub get`
- Format: `fvm dart format .`
- Analyze: `fvm flutter analyze`
- Fast full test pass: `make flutter_test` (`fvm flutter test test --no-pub --test-randomize-ordering-seed random`)
- Single test file: `fvm flutter test path/to_test.dart`
- Coverage: `./scripts/coverage.sh` (`lcov` required; filters generated files plus `lib/bootstrap.dart` and `lib/firebase_options.dart`)
- Codegen: `make flutter_generate`
- Patrol release-gate E2E: `PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall`
- Optional legacy integration sweep: `fvm flutter test integration_test`

## Verify order
- Default: `fvm flutter analyze` -> `make flutter_test`
- If translations or generated code changed: run `make flutter_generate` before analyze/test
- If app-shell or premium/history flows changed: run relevant `integration_test/` or Patrol journey

## Architecture
- Real app entrypoint: `lib/main.dart`. It initializes Firebase, App Check, Crashlytics, RevenueCat, Localizely, SharedPreferences, Sembast DB, then runs startup migrations before bootstrapping Riverpod overrides.
- Root widget: `lib/app/app.dart`. Main shell: `lib/app/app_page.dart`.
- Main feature boundaries: `lib/calculator/`, `lib/history/`, `lib/settings/`, `lib/database/`, `lib/purchases/`, `lib/shared/`.
- `HistoryPage` exists only for premium users; `AppPage` dynamically removes that tab for free users.

## Testing quirks
- Widget tests should use `test/helpers/helpers.dart`; it installs mock SharedPreferences, in-memory Sembast, no-op analytics, and localization delegates.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`; it seeds in-memory DB/prefs and fake purchases for free vs premium flows.
- Startup/migration behavior has dedicated coverage in `test/main_migration_test.dart`; keep migration order stable when touching bootstrap/database startup.

## Localisation
- Never leave user-facing copy hardcoded when existing l10n system should be used.
- ARB source: `lib/l10n/arb/`. Generated strings are consumed from `lib/generated/l10n.dart`.
- Update all supported locales when adding/changing keys. Reuse existing wording patterns. Use placeholders, not string concatenation.
- Do not localize developer-only strings such as logs, debug messages, test descriptions, identifiers, analytics keys, or API field names unless explicitly required.

## Workflow notes
- Prefer FVM-backed commands locally even if some CI jobs call plain `flutter`/`dart`.
- `make bump_fix`, `make bump_feat`, `make bump_build` update app version; maintenance workflow uses `make bump_fix` after analyze/test pass.
