

# App Store Metadata Rules

## Purpose

This document contains the character limits, localization guidelines, and content rules used for app store metadata and screenshot generation.

---

# Google Play Store

| Field | Limit |
|---|---|
| App Name | 30 characters |
| Short Description | 80 characters |
| Full Description | 4,000 characters |

---

# Apple App Store

| Field | Limit |
|---|---|
| App Name | 30 characters |
| Subtitle | 30 characters |
| Promotional Text | 170 characters |
| Keywords | 100 characters |
| Description | 4,000 characters |

---

# Screenshot Guidelines

These are internal project limits intended to remain safe across all supported localizations.

| Field | Recommended Limit |
|---|---|
| Screenshot heading line 1 | 18 characters or less |
| Screenshot heading line 2 | 18 characters or less |
| Combined heading | 30 characters or less |
| CTA text | 12 characters or less |
| Supporting text | Avoid where possible |

---

# Localization Rules

Always optimize screenshots for translated text rather than English text.

Guidelines:

- Prefer 1–3 words per screenshot heading.
- Avoid full marketing sentences.
- Avoid feature lists in screenshots.
- Avoid punctuation unless required.
- Prefer simple nouns and verbs.
- Keep wording easy to translate.

Expected expansion:

| Language | Expansion |
|---|---|
| German | 30–50% |
| French | 20–40% |
| Italian | 20–40% |
| Spanish | 15–35% |

If text is close to the limit in English, assume it will not fit in German.

---

# Screenshot Caption Strategy

Current preferred style:

- True Print Cost
- Not Just Filament
- Import G-Code
- Batch Costing
- Pricing Tools
- Offline First

Characteristics:

- Short
- Feature-focused
- Easy to localize
- Consistent across stores

Avoid:

- Long marketing claims
- Multiple concepts in one heading
- Excessive punctuation
- Large text blocks

---

# Metadata Update Checklist

Before publishing:

- Verify Google Play limits.
- Verify App Store limits.
- Verify Premium and Free feature ownership.
- Verify screenshot captions remain accurate.
- Verify screenshot captions fit localized layouts.
- Verify changelog matches shipped functionality.
- Verify paywall messaging matches store messaging.
- Verify website copy matches store positioning.

---

# Ownership

Store metadata, screenshot copy, and localization guidance should be maintained here rather than inside Fastlane-generated documentation.