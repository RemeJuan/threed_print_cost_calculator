# What's New / Announcement System

## Payload Structure

```json
{
  "wn_id": "gcode_import_2026_04",
  "en": {
    "title": "New: Import G-code estimates",
    "body": "Import supported G-code files to prefill print time, filament usage, and preview data where available. Open it from the header bar icon in the top right.",
    "cta": "Got it",
    "unlock_pro_cta": "Start free trial"
  }
}
```

## Field Semantics

| Field | Type | Description |
|-------|------|------------|
| `wn_id` | String | Announcement identity used by the payload. |
| `{locale}` | Object | Locale-specific content (e.g., `en`, `de`, `fr`). |
| `title` | String | **Required** localized title. |
| `body` | String | **Required** localized body. |
| `cta` | String | Primary CTA button text. Optional. |
| `unlock_pro_cta` | String | Trial CTA button text. Optional. |

## Localization Rules

- Locales are top-level keys (e.g., `en`, `de`, `fr`).
- Resolve locale via `Localizations.localeOf(context).languageCode`.
- Fallback to `en` if missing.
- Required localized fields: `title`, `body`.
- Optional localized fields: `cta`, `unlock_pro_cta`.
- Missing required fields or invalid JSON should fail silently.

## Persistence

- Store dismissed ID using `dismissed_announcement_id`.
- Show once per `wn_id`.
- User dismisses → save `wn_id` to prefs → don't show again.

## Display Rules

- Show to **all users** (free and premium).
- Do **not** respect "hide upsells" preference — this is an announcement, not persistent upsell UI.
- Primary CTA (`cta`) dismisses the sheet and stores `wn_id`.
- Unlock Pro CTA (`unlock_pro_cta`) logs trial attribution, dismisses the sheet, and then opens the paywall.
- No persistent UI, badges, inline rows, or icon replacement.

## Analytics
- Sheet open/dismiss still tracked by `whats_new_shown` / `whats_new_dismissed`.
- Unlock Pro CTA logs `whats_new_unlock_pro_tapped` with `wn_id`, `locale`, and `source=whats_new`.
- Unlock Pro CTA also emits `premium_feature_tapped(feature=whats_new, source=whats_new)` and then paywall analytics from the presenter.
- Pro CTA attribution stays low-cardinality; no body/title text is logged.

## Rationale

This preserves clean UI, avoids dark patterns, and still informs free users about hidden Pro features without adding persistent clutter.
