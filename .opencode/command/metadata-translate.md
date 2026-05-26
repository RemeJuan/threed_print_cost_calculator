---
description: Update non-English App Store / Play Store metadata from English source files, validate it, and commit changes without pushing
agent: build
---

Update translated store metadata for **3D Print Cost Calculator** using the active model in this opencode session.

This command is **translation + commit only**.

Do **not** push metadata to App Store Connect or Google Play.

## Goal

Use the English metadata files as the source of truth, update the non-English locale files in `fastlane/metadata/`, validate the result, and create a git commit if files changed.

## Source files

Use these English trees as source:

- iOS reference copy: `fastlane/metadata/ios/en-US/`
- iOS push-compatible English locale: en-GB (default ASC locale; content sourced from `fastlane/metadata/ios/en-US/`)
- Android reference copy: `fastlane/metadata/android/en-US/`

## Target locales

### iOS

Update:

- `fastlane/metadata/ios/de-DE/`
- `fastlane/metadata/ios/pt-BR/`
- `fastlane/metadata/ios/es-ES/`
- `fastlane/metadata/ios/fr-FR/`
- `fastlane/metadata/ios/it/`
- `fastlane/metadata/ios/ja/`

For each locale, update these translated text files when present:

- `name.txt`
- `subtitle.txt`
- `description.txt`
- `keywords.txt`
- `release_notes.txt`

Do **not** generate or touch these non-localizable files:

- `support_url.txt`
- `marketing_url.txt`
- `privacy_url.txt`
- `apple_tv_privacy_policy.txt`
- `promotional_text.txt`

These files exist only in the default locale dir (`en-US`) as single-copy shared values.
They are removed from non-English locale directories — do not recreate them there.

### Android

Update:

- `fastlane/metadata/android/de-DE/`
- `fastlane/metadata/android/pt-BR/`
- `fastlane/metadata/android/es-ES/`
- `fastlane/metadata/android/fr-FR/`
- `fastlane/metadata/android/it-IT/`
- `fastlane/metadata/android/ja-JP/`

For each locale, update:

- `title.txt`
- `short_description.txt`
- `full_description.txt`
- `changelogs/default.txt`

For Android release notes, treat `fastlane/metadata/android/en-US/changelogs/default.txt` as the source of truth.

- Update every Android locale's `changelogs/default.txt` from the latest English source.
- Create missing locale changelog files unconditionally.
- Overwrite existing locale `default.txt` files from the current English source.
- Do not create or preserve version-code changelog files.

## Translation rules

1. Translate from the latest English copy in the repo.
2. Preserve product meaning and feature parity across stores.
3. Keep copy natural for the target locale, not word-for-word robotic.
4. Preserve formatting structure:
   - blank lines
   - bullets
   - section headings
   - simple punctuation style when it already works
5. Preserve brand/product names and technical terms when translation would sound wrong.
6. Preserve file purpose and store constraints.
7. Never leave `TODO TRANSLATE:` markers.
8. Never push to store consoles.
9. For Android changelogs, keep the locale `default.txt` files aligned with English source.

## Hard limits and store constraints

Respect these limits while translating:

- iOS `name.txt`: 30 chars max
- iOS `subtitle.txt`: 30 chars max
- iOS `keywords.txt`: 100 chars max
- Android `title.txt`: 50 chars max
- Android `short_description.txt`: 80 chars max
- iOS / Android descriptions: 4000 chars max
- Android changelogs should stay concise and store-safe for release notes

If a direct translation is too long, rewrite it naturally to fit.

## Required workflow

1. Inspect the current English source files and target locale files.
2. Update only metadata translation files relevant to the English source content.
3. Keep unchanged files untouched when translation does not need revision.
4. Run validation:

   ```bash
   ./scripts/validate_metadata.sh
   ```

5. Review the diff for obvious mistakes, truncation problems, or broken formatting.
6. Stage only metadata translation changes and any directly related docs/config touched by this command.
7. Create a git commit if and only if there are actual translation changes.

## Commit rules

- Do not commit unrelated working tree changes.
- Prefer a concise commit message such as:
  - `chore: update store metadata translations`
  - or a more specific variant if only release notes changed
- If no translation files changed, report that and do not create an empty commit.

## Do not do

- Do not run `fastlane ... metadata_push`
- Do not run `make metadata_push_ios`
- Do not run `make metadata_push_android`
- Do not modify binary/release workflows
- Do not translate app code l10n files under `lib/l10n/`

## Final output

Return:

1. which English source files drove the updates
2. which locale files changed
3. validation result
4. commit hash and message, or why no commit was created
