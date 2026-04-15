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
- If `intl_*.arb` changes but `lib/l10n/app_localizations.dart` does not, treat that as a broken sync and fix it before finishing
- If app-shell or premium/history flows changed: run relevant `integration_test/` or Patrol journey

## Architecture
- Real app entrypoint: `lib/main.dart`. It initializes Firebase, App Check, Crashlytics, RevenueCat, Localizely, SharedPreferences, Sembast DB, then runs startup migrations before bootstrapping Riverpod overrides.
- Root widget: `lib/app/app.dart`. Main shell: `lib/app/app_page.dart`.
- Main feature boundaries: `lib/calculator/`, `lib/history/`, `lib/settings/`, `lib/database/`, `lib/purchases/`, `lib/shared/`.
- `HistoryPage` exists only for premium users; `AppPage` dynamically removes that tab for free users.

## Testing quirks
- Widget tests should use `test/helpers/helpers.dart`; it installs mock SharedPreferences, in-memory Sembast, no-op analytics, and `AppLocalizations.localizationsDelegates`.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`; it seeds in-memory DB/prefs and fake purchases for free vs premium flows.
- Startup/migration behavior has dedicated coverage in `test/main_migration_test.dart`; keep migration order stable when touching bootstrap/database startup.

## Localisation
- Never leave user-facing copy hardcoded when the existing l10n system should be used.
- Source of truth for app strings: `lib/l10n/intl_*.arb`
- After any ARB change, run: `fvm flutter gen-l10n`
- Never manually edit generated localisation files.
- Use the project’s existing generated localisation access pattern consistently. Do not introduce a second localisation API in new code.
- If adding a new key, update the English ARB first, regenerate, then update all supported locale ARBs.
- Update all supported locales when adding or changing keys. Reuse existing wording patterns. Use placeholders instead of string concatenation.
- Audit every changed widget, dialog, banner, snackbar, and empty state for hardcoded user-facing text before merge.
- Keep developer-only strings out of l10n, including logs, debug messages, test descriptions, identifiers, analytics keys, and API field names, unless explicitly required.
- Sample or preview data may stay hardcoded when it is clearly demo content rather than product UI copy.
- Prefer passing localized strings into pure helpers rather than reading localisation state inside them.

## File Layout
- One widget per file. Keep each widget in its own Dart file, including helper sheets/dialogs/teaser states.
- If a file grows a second widget, split it before merging.

## Workflow notes
- Prefer FVM-backed commands locally even if some CI jobs call plain `flutter`/`dart`.
- `make bump_fix`, `make bump_feat`, `make bump_build` update app version; maintenance workflow uses `make bump_fix` after analyze/test pass.

## Changelog rules
- CHANGELOG.md is user-facing but more detailed than store notes
- Only include changes with user impact
- Keep structure consistent (Added, Changed, Fixed)
- New entries go at the top