# Store Localisation

Metadata management for App Store Connect and Google Play, powered by [Fastlane](https://fastlane.tools).

**Character limits, screenshot guidelines, and content rules:** `docs/app_store_metadata_rules.md`

## Overview

All store metadata lives in `fastlane/metadata/` as plain text files tracked in git. No SaaS tools required.

```
fastlane/metadata/
  ios/             # App Store Connect metadata (deliver)
    en-GB/         # English (reference / default ASC locale)
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

Notes:
- Every iOS `description.txt` must retain the App Store standard EULA link: `EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`

### Android (`fastlane/metadata/android/<locale>/`)

| File | Description | Required |
|------|-------------|----------|
| `title.txt` | App name (50 chars max) | Yes |
| `short_description.txt` | Short description (80 chars max) | Yes |
| `full_description.txt` | Full description (4000 chars max) | Yes |
| `video.txt` | YouTube promo video URL | No |
| `changelogs/default.txt` | Release notes for the locale | Yes |

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
   - Feature releases: usually pair this with description/subtitle/keywords updates
   - Patch releases: push only `release_notes.txt` with `make metadata_push_ios_changelog`
2. Edit `fastlane/metadata/android/<locale>/changelogs/default.txt` for Android
    - One default file per locale keeps the store copy simple
    - English stays the source of truth; translation sync updates each locale's `default.txt`
   - Patch releases: push only changelogs with `make metadata_push_android_changelog [TRACK=open_testing]`

### Generate translated metadata with opencode

Use the project command:

```bash
/metadata-translate
```

What it does:

- reads English source metadata from `fastlane/metadata/ios/en-GB/` and `fastlane/metadata/android/en-US/`
- updates non-English locale files in `fastlane/metadata/` — including `name.txt`, `subtitle.txt`, `description.txt`, `keywords.txt`, `release_notes.txt` (iOS) and `title.txt`, `short_description.txt`, `full_description.txt`, `changelogs/*.txt` (Android)
- for Android changelogs: English source directory is the only source of truth — update `en-US/changelogs/default.txt` and sync the same `default.txt` into every Android locale
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
make metadata_push_ios_changelog
make metadata_push_android
make metadata_push_android_changelog TRACK=open_testing
```

Or use scripts directly:
```bash
./scripts/metadata_push_ios.sh
./scripts/metadata_push_ios_changelog.sh
./scripts/metadata_push_android.sh
./scripts/metadata_push_android_changelog.sh open_testing
```

**What gets pushed:**
- iOS metadata lane: full metadata, including `release_notes.txt`, uploaded from real locale folders (`en-GB/`, `de-DE/`, etc.) — no binary (`skip_binary_upload`), no screenshots (`skip_screenshots`)
- iOS changelog lane: `release_notes.txt` only from real locale folders — useful when only What's New changes
- Android: metadata only — no APK/AAB (`skip_upload_apk`, `skip_upload_aab`), no images (`skip_upload_images`), includes changelogs
- Android changelog lane: `changelogs/default.txt` only — title/short/full description and screenshots stay untouched

**What does not happen:**
- No binary upload
- No screenshot upload
- No submission for review (iOS)
- Track: Android pushes to `beta` by default (configurable via `METADATA_TRACK`)

**Android changelog-only caveat:**
- Google Play changelog uploads need an existing release context
- The lane auto-resolves the latest version code from `open_testing` by default
- Override `TRACK` only if a different test track should be used
- `default.txt` is used as the fallback changelog content for that version code

### Push screenshots

Screenshots are uploaded separately from metadata so translation deploys stay metadata-only.

```bash
make screenshots_push_ios
make screenshots_push_android
make screenshots_push_all
```

Or use scripts directly:

```bash
./scripts/screenshots_push_ios.sh
./scripts/screenshots_push_android.sh
```

**What gets pushed:**
- iOS: screenshots from `fastlane/screenshots/output/ios/`
- Android: screenshots from `fastlane/screenshots/output/android/`, staged into Play screenshot folders for phone, seven-inch, and ten-inch listings

**What does not happen:**
- No metadata upload
- No binary upload
- No submission for review
- Existing screenshots on App Store Connect are preserved; the lane does not overwrite the whole set

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
   cp -r fastlane/metadata/ios/en-GB fastlane/metadata/ios/<new-locale>
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
- Changelogs use `changelogs/default.txt` per locale. Keep the current release note there and update it when the next release is ready.
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

## Screenshot generation

Localised store screenshots are generated from fixed app screenshots (JPG) with template-driven heading text overlays.

### Principles

- Base images are final app screenshots, **not modified in place**
- Only the marketing heading text at the top of each image is overlaid
- Phone UI, Pro badges, gradients, and all other visual elements remain untouched
- Explicit per-format, per-asset layout metadata (`layout.yaml`) defines `x`, `y`, `max_width`, `font_size`, `line_height`, `align`, `wrap`, and `fit_mode`
- No auto-wrapping, OCR, or layout inference — fixed coordinates only

### File layout

```
fastlane/screenshots/
  layout.yaml           # Per-format per-asset heading coordinates & font sizes
  base/
    ios/                # iOS screenshots (1284×2778)
      batch_quotes.jpg
      calculator_free.jpg
      calculator_pro.jpg
      gcode_import.jpg
      history_export.jpg
      materials.jpg
      settings_free.jpg
      settings_pro.jpg
    android/            # Android screenshots (same filenames, native ratio)
      ...
  copy/                 # Per-locale heading text (segment arrays)
    en-GB.yaml
    de-DE.yaml
    ...
  output/               # Generated PNG — gitignored
    6.5/
      en-GB/
        batch_quotes.png
        calculator_free.png
        ...
        name.txt
      de-DE/
        ...
```

### Layout metadata (`layout.yaml`)

Each asset defines explicit layout fields at the base resolution:

```yaml
formats:
  "6.5":
    assets:
      batch_quotes:
        source: batch_quotes.jpg
        x: 188
        y: 195
        max_width: 865
        font_size: 50
        line_height: 60
        align: center
        wrap: false
        fit_mode: shrink_to_fit

      settings_pro:
        source: settings_pro.jpg
        x: 324
        y: 83
        max_width: 633
        font_size: 65
        line_height: 85
        align: center
        wrap: false
        fit_mode: shrink_to_fit
```

### Copy format (YAML)

Each locale file uses multi-segment headings for two-tone primary/accent styling:

```yaml
locale: en-GB
name: "3D Print Cost Calculator"      # optional iOS name.txt; omitted → not generated
screenshots:
  - asset: batch_quotes
    heading:
      - text: "Quote"
        style: accent
      - text: " Multiple Prints"
        style: primary

  - asset: settings_pro
    heading:
      - line:                           # multi-line heading
          - text: "No Accounts."
            style: accent
      - line:
          - text: "No Cloud."
            style: primary
      - line:
          - text: "Just Works."
            style: accent
```

- `heading` is an array of segments. Use `line:` entries only when the copy should be multi-line.
- Each segment has `text` (string) and `style` (`primary` = #FFFFFF, `accent` = #5499FE)
- `name` is optional — only locales with `name` get `name.txt` (iOS only)

### Workflow

1. Add/replace base JPGs under `fastlane/screenshots/base/ios/` or `base/android/`
2. Update heading box coordinates in `fastlane/screenshots/layout.yaml`
3. Edit locale YAML files under `fastlane/screenshots/copy/`
4. Run the generator:

```bash
make generate_screenshots       # all platforms + all locales
make generate_screenshots_ios   # iOS only
make generate_screenshots_android  # Android only
```

Or directly:

```bash
python3 scripts/generate_screenshots.py --formats ios --locale en-GB
```

The script:
- reads base JPGs without modifying them
- renders heading segments at fixed per-asset coordinates using Inter Bold at configured font size
- applies `shrink_to_fit` only when a translated line exceeds its `max_width`
- writes locale-specific output folders as PNG (required by stores)

### Options

| Flag | Description |
|------|-------------|
| `--locale LOCALE` | Generate only one locale (e.g. `--locale de-DE`) |
| `--formats LIST` | Comma-separated formats: `6.5`, `5.5`, `android-phone`, `android-tablet-7`, `android-tablet-10`, `WxH`, `ios`, `android`, `all` (default: `6.5`) |
| `--skip-missing` | Skip missing base images instead of failing |
| `--font PATH` | Heading font (default: `assets/fonts/inter/Inter-Bold.ttf`) |

### Error behaviour

- Missing locale copy → exits with `ERROR: Missing copy for locales: ...`
- Missing `screenshots` key or malformed segments → exits with a descriptive message
- Asset ID not found in layout → exits with a descriptive message
- Base image not found → exits (or skips with `--skip-missing`)

### Adding a new locale

1. Create `fastlane/screenshots/copy/<locale>.yaml` with `asset` → `heading` entries for each screenshot
2. Run `make generate_screenshots` or `python3 scripts/generate_screenshots.py --formats all`

### Updating heading positions

If the base screenshots change dimensions or heading design, update the format-specific asset coordinates in `layout.yaml`:

1. Open each new base screenshot in an image editor
2. Note the heading area's `x`, `y`, `max_width`, `line_height`, and `align` in pixels
3. Update the format-specific asset values in `layout.yaml`
4. Adjust `font_size` or `fit_mode` if text no longer fits comfortably

### Prerequisites

Python 3 with Pillow and PyYAML:

```bash
pip install -r scripts/requirements_screenshots.txt
```

The `make` target handles dependency setup automatically via a virtualenv.

---

## Tips for solo developer shipping every 2 weeks

1. **Keep release notes in git from day one.** Edit them during development, not at release time.
2. **Push metadata early.** You can update description/keywords between binary submissions.
3. **Use `make metadata_validate` as a pre-commit hook** to catch untranslated or missing files.
4. **Diff before push** — `make metadata_diff` catches accidental whitespace changes.
5. **Android changelogs use `default.txt`.** Update the locale's default note when you prepare the next release.
