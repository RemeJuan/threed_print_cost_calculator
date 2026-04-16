# Workflow Rules

## Coding rules

- Use existing Riverpod providers and hooks patterns.
- Keep one widget per file.
- Do not add hardcoded user-facing copy when an existing l10n key fits.
- If a new string is needed, update `lib/l10n/intl_en.arb`, regenerate, then sync every locale ARB.

## Testing

- Widget tests should use `test/helpers/helpers.dart`.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`.
- Prefer `fvm flutter analyze` then `make flutter_test` before finishing.
- Run `make flutter_generate` first if generated code or localization changed.

## Useful commands

- Setup: `fvm flutter pub get`
- Format: `fvm dart format .`
- Analyze: `fvm flutter analyze`
- Tests: `make flutter_test`
- Codegen: `make flutter_generate`
- Localization: `fvm flutter gen-l10n`

## Notes for agents

- `main.dart` does startup work, so changes there can affect migrations and boot order.
- `HistoryPage` and premium flows are covered by integration tests; keep those journeys stable.
