# Store Localisation

Metadata management for App Store Connect and Google Play, powered by [Fastlane](https://fastlane.tools).

## Overview

All store metadata lives in `fastlane/metadata/` as plain text files tracked in git. No SaaS tools required.

```
fastlane/metadata/
  ios/             # App Store Connect metadata (deliver)
    en-US/         # English (reference)
    de-DE/         # German
    pt-BR/         # Portuguese (Brazil)
    es-ES/         # Spanish (Spain)
    fr-FR/         # French (France)
    it/            # Italian
    ja/            # Japanese
  android/         # Google Play metadata (supply)
    en-US/         # English (reference)
    de-DE/
    pt-BR/
    es-ES/
    fr-FR/
    it-IT/
    ja-JP/

> **Locale difference**: iOS and Android both use BCP-47 codes. Main difference: iOS uses `it`/`ja` (region-neutral), Android uses `it-IT`/`ja-JP`.

---

## File structure

### iOS (`fastlane/metadata/ios/<locale>/`)

| File | Description | Required |
|------|-------------|----------|
| `name.txt` | App name (30 chars max) | Yes |
| `subtitle.txt` | Subtitle (30 chars max) | Yes |
| `description.txt` | Full description (4000 chars max) | Yes |
| `keywords.txt` | Comma-separated keywords (100 chars max) | Yes |
| `release_notes.txt` | What's New text for the latest version | Yes |
| `support_url.txt` | Support URL | Yes |
| `marketing_url.txt` | Marketing URL | No |
| `privacy_url.txt` | Privacy policy URL | Yes (if app uses) |

### Android (`fastlane/metadata/android/<locale>/`)

| File | Description | Required |
|------|-------------|----------|
| `title.txt` | App name (50 chars max) | Yes |
| `short_description.txt` | Short description (80 chars max) | Yes |
| `full_description.txt` | Full description (4000 chars max) | Yes |
| `video.txt` | YouTube promo video URL | No |
| `changelogs/<version-code>.txt` | Release notes per version | Per version |

---

## Workflow

### Prerequisites

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Set up credentials (one-time):

   **iOS (App Store Connect API Key)**:
   - Generate an API key at [appstoreconnect.apple.com/access/api](https://appstoreconnect.apple.com/access/api)
   - Ensure the key has "Admin" or "App Manager" role for metadata access
   - Export these env vars (or add to `fastlane/.env` — this file is gitignored):
     ```bash
     export APP_STORE_CONNECT_ISSUER_ID="your-issuer-id"
     export APP_STORE_CONNECT_KEY_IDENTIFIER="your-key-id"
     export APP_STORE_CONNECT_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
     ```

   **Android (Google Play Service Account)**:
   - Create a service account in Google Cloud Console, grant it "View app information" + "Edit store listing" permissions in Google Play Console
   - Download the JSON key and export:
     ```bash
     export SUPPLY_JSON_KEY_DATA='{ ... }'
     ```

### Pull latest metadata

Downloads current store listings into the repo so you can edit them locally:

```bash
make metadata_pull
```
or
```bash
./scripts/metadata_pull.sh
```

This calls `fastlane deliver --metadata_only` (iOS) and `fastlane supply` (Android) to sync current store content into `fastlane/metadata/`.

Run this once to bootstrap, then periodically to catch any changes made directly in the console.

### Update release notes

1. Edit `fastlane/metadata/ios/<locale>/release_notes.txt` for iOS
2. Create `fastlane/metadata/android/<locale>/changelogs/<new-version-code>.txt` for Android
   - Version code matches the `+N` in pubspec.yaml (e.g. `2.11.0+8` → `8`)
   - Previous version changelogs remain as history
   - Changelog files exist only in the English source directory (`en-US/changelogs/`) initially. Non-English locale changelogs are created from English during translation sync.

### Generate translated metadata with opencode

Use the project command:

```bash
/metadata-translate
```

What it does:

- reads English source metadata from `fastlane/metadata/ios/en-US/`, `fastlane/metadata/ios/en-GB/`, and `fastlane/metadata/android/en-US/`
- updates non-English locale files in `fastlane/metadata/` — including `name.txt`, `subtitle.txt`, `description.txt`, `keywords.txt`, `release_notes.txt` (iOS) and `title.txt`, `short_description.txt`, `full_description.txt`, `changelogs/*.txt` (Android)
- for Android changelogs: English source directory is the only source of truth — new version-code files exist only in `en-US/changelogs/` first, the command creates matching translated files per locale
- runs `./scripts/validate_metadata.sh`
- creates a git commit for translation changes only

What it does **not** do:

- no App Store Connect push
- no Google Play push
- no binary upload

### Push metadata changes

**Dry-run first** — preview what will change:

```bash
make metadata_diff        # diff all metadata
make metadata_diff_ios    # iOS only
make metadata_diff_android # Android only
```

Then push:

```bash
# Validate first
make metadata_validate

# Push to individual stores
make metadata_push_ios
make metadata_push_android
```

Or use scripts directly:
```bash
./scripts/metadata_push_ios.sh
./scripts/metadata_push_android.sh
```

**What gets pushed:**
- iOS: metadata only — no binary (`skip_binary_upload`), no screenshots (`skip_screenshots`)
- Android: metadata only — no APK/AAB (`skip_upload_apk`, `skip_upload_aab`), no images (`skip_upload_images`)

**What does not happen:**
- No binary upload
- No screenshot upload
- No submission for review (iOS)
- Track: Android pushes to `beta` by default (configurable via `METADATA_TRACK`)

---

## Rollback

Since metadata is git-managed, rollback is simply reverting to a previous commit:

```bash
# See what changed in the last push
git log --oneline -- fastlane/metadata/

# Revert to a known-good state
git revert HEAD
# or reset to a specific commit
git checkout <commit-hash> -- fastlane/metadata/
```

Then re-push the reverted metadata:
```bash
make metadata_push_ios
make metadata_push_android
```

> **Note**: App Store Connect and Google Play do not have a "restore previous" button. A git revert followed by a push is the fastest rollback.

---

## Adding a new locale

1. Copy the English reference folder:
   ```bash
   cp -r fastlane/metadata/ios/en fastlane/metadata/ios/<new-locale>
   cp -r fastlane/metadata/android/en-US fastlane/metadata/android/<new-locale-android>
   ```
2. Replace content with translations (remove the placeholder prefix)
3. Update the validation script's locale arrays
4. Commit and push

Refer to Apple's [list of supported locales](https://help.apple.com/app-store-connect/#/dev997f9cf3c) and Google's [locale codes](https://support.google.com/googleplay/android-developer/answer/9844778) for valid directory names.

---

## Common pitfalls

### iOS

- `name.txt` **must be 30 characters or fewer**. Longer names are rejected by deliver.
- `keywords.txt` has a 100-character limit. Only counts in the default locale (English) — non-English keywords are typically ignored by the App Store.
- `description.txt` may contain limited HTML: `<br>`, `<li>`, `<b>`, etc. Avoid `<a>` tags and `<style>` blocks.
- Emoji in app names can cause submission issues. Stick to text.
- After push, metadata updates are staged but not submitted. You must manually submit via App Store Connect.
- App Store Connect may revert `subtitle` changes if they conflict with in-app purchase wording — verify on the dashboard.

### Android

- `title.txt` limit is 50 characters (30 on some older Play Store versions).
- `short_description.txt` is strict **80 characters**. Truncation happens server-side.
- Google Play indexes `full_description.txt` for search. Include relevant keywords naturally.
- HTML is supported in `full_description.txt` but keep it simple: `<b>`, `<i>`, `<li>`.
- Changelogs are per-version-code files. Each version you upload needs its own `changelogs/<code>.txt`.
- Changed metadata can take 2–24 hours to appear in Play Store search results.
- Google Play caches metadata. Use the "View as user" preview on the console to confirm changes.

---

## CI

A GitHub Actions workflow at `.github/workflows/metadata-push.yml` supports:

- **Manual trigger**: `workflow_dispatch` with platform selector
- **Auto-validation**: Runs `validate_metadata.sh` before any push
- **Environment secrets**: Uses GitHub Actions secrets for API credentials

To enable CI, add these secrets to your GitHub repository:

| Secret | Description |
|--------|-------------|
| `ASC_ISSUER_ID` | App Store Connect API issuer ID |
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_PRIVATE_KEY` | App Store Connect API private key |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Google Play service account JSON |

### Fastlane env reference

| Variable | Used by | Required |
|----------|---------|----------|
| `APP_STORE_CONNECT_ISSUER_ID` | `deliver` (iOS) | Yes |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | `deliver` (iOS) | Yes |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `deliver` (iOS) | Yes |
| `SUPPLY_JSON_KEY_DATA` | `supply` (Android) | Yes |

---

## Tips for solo developer shipping every 2 weeks

1. **Keep release notes in git from day one.** Edit them during development, not at release time.
2. **Push metadata early.** You can update description/keywords between binary submissions.
3. **Use `make metadata_validate` as a pre-commit hook** to catch untranslated or missing files.
4. **Diff before push** — `make metadata_diff` catches accidental whitespace changes.
5. **Android changelogs are per version.** Create the next changelog file (`<next-version-code>.txt`) immediately after each release so you don't forget what changed.
