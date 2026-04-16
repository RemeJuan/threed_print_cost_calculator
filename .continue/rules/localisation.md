# Localisation

## Source of truth

- App strings live in `lib/l10n/intl_*.arb`.
- `l10n.yaml` uses `lib/l10n/intl_en.arb` as the template file and generates `lib/l10n/app_localizations.dart`.
- Supported locales: `en`, `es`, `de`, `fr`, `it`, `ja`, `nl`, `pt`, `th`, `id`.

## Rules

- Do not leave product UI copy hardcoded when an existing l10n key fits.
- Add the English ARB first, regenerate, then sync the other locale ARBs.
- Never edit generated localization files by hand.
- Prefer placeholders over string concatenation.

## Workflow

- After any ARB change, run `fvm flutter gen-l10n`.
- Audit changed widgets, dialogs, banners, snackbars, and empty states for stray hardcoded UI text before merge.
