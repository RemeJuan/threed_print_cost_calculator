# Coding Standards

## Layout

- Keep one widget per file.
- Keep helper dialogs, sheets, and teaser states in their own files when they become separate widgets.
- Mirror `lib/` structure in `test/`.

## Flutter patterns

- Reuse the existing Riverpod + hooks patterns already in the repo.
- Prefer `final` where values do not change.
- Use existing providers and helpers instead of adding parallel state or utility layers.

## Generated code

- Do not edit generated files by hand.
- Generated outputs in this repo include `lib/l10n/app_localizations.dart`, `*.freezed.dart`, and `*.g.dart`.

## Tests

- Widget tests should use `test/helpers/helpers.dart`.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`.
- Keep `test/main_migration_test.dart` stable when touching startup or database boot order.

## User-facing text

- Do not add hardcoded UI copy when an existing localization key fits.
- Keep developer-only strings out of localization files.
