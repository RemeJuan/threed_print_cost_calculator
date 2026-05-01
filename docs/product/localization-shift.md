# Localization shift

## Context
- Existing localization approach was slowing agent/developer workflows.
- Recent materials work added new UI flows that needed an explicit l10n audit.

## Decisions
- Shift toward generated `AppLocalizations` access pattern.
- New user-facing copy in materials flows must ship through ARB files before merge.

## Tradeoffs
- Migration cost across existing UI surface.
- Better automation and consistency after migration.

## Rejected Ideas
- None recorded in backfill.
- TODO: verify in code if hybrid localization access was discussed and rejected.

## Implementation Notes
- Migration is ongoing/incomplete based on backfill context.
- Materials CSV import and stock badge UI were audited and moved to l10n-backed strings.
- New materials keys were propagated across all currently supported locales: `en`, `pt`, `es`, `fr`, `de`, `it`, `ja`, `nl`, `th`, `id`.

## Known Issues
- Hardcoded strings may still exist in some UI flows.

## TODOs
- Complete migration.
- Remove remaining hardcoded user-facing strings.
- Keep widget tests using `lookupAppLocalizations(const Locale('en'))` where direct string expectations are needed.
