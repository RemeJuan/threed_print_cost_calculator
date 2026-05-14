---
description: Investigate technical-investment opportunities and produce PR-sized maintenance recommendations
agent: plan
---

Perform a broad project maintenance review for the Flutter app **3D Print Cost Calculator**.

This is an investigation-only command. Do not change files unless explicitly instructed after the review.

## Context

This app is a local-first iOS/Android Flutter app for calculating real 3D print costs, including filament, electricity, printer profiles, failure risk, labour, history, materials, and settings.

Preserve these architectural principles:
- deterministic domain logic
- offline-first/local-first storage
- separation between UI and business logic
- RevenueCat-backed premium gating
- small, reviewable changes

## Review Goals

Identify practical technical-investment work that can become focused ClickUp tasks or small PRs.

Prioritize:
- large files that are doing too much
- files with multiple widgets/classes that should be split
- duplicated helpers or repeated state handling
- UI/domain boundary leaks
- stale, dead, or low-confidence code
- test coverage gaps
- fragile async or persistence flows

Avoid theoretical rewrites. Focus on changes that reduce maintenance cost without changing behaviour.

## Review Areas

### 1. Large files

- Identify unusually large Dart files.
- Flag files that are doing too much.
- Recommend sensible extraction targets.
- Prioritize splits that improve readability without behaviour changes.

### 2. Widget structure

- Find files containing multiple widgets/classes that should probably be separated.
- Pay attention to screens, forms, settings pages, cards, dialogs, and reusable UI components.
- Recommend new file names and folder locations.
- Do not split private helper widgets unless the file is clearly hard to maintain.

### 3. UI/domain separation

- Look for business logic inside widgets.
- Look for calculation, validation, formatting, persistence, entitlement, or export logic leaking into UI.
- Recommend moving logic into services, providers, helpers, or domain files where appropriate.

### 4. Dead or stale code

- Identify unused files, unused imports, unused widgets, stale comments, TODOs, old debug helpers, and duplicated code.
- Do not remove anything blindly.
- Mark each candidate with a confidence level: high, medium, or low.

### 5. Test coverage opportunities

Identify focused test opportunities for:
- cost calculation logic
- G-code import
- material and printer management
- premium gating
- history save/export
- settings validation
- provider/notifier behaviour

Recommend focused unit/provider/widget tests. Avoid broad snapshot-style tests.

### 6. Maintainability risks

Flag:
- complex conditionals
- duplicated state handling
- fragile async flows
- hardcoded user-facing strings
- repeated UI patterns
- inconsistent naming
- circular dependency risks

## Constraints

- Do not introduce new packages.
- Do not change app behaviour.
- Do not refactor during this command.
- Do not apply fixes during this command.
- Prefer PR-sized recommendations.
- Preserve local-first/offline-first architecture.
- Keep RevenueCat and premium gating behaviour intact.
- Avoid cosmetic-only churn unless it materially improves readability.

## Output Format

Return a concise report with these sections:

### Summary

List the highest-value findings in priority order.

### Findings

Use this table:

| File | Issue | Risk | Suggested cleanup | Effort |
| --- | --- | --- | --- | --- |
| `<path>` | `<issue>` | `<low/medium/high>` | `<recommendation>` | `<S/M/L>` |

### Safe Quick Wins

List low-risk tasks suitable for immediate delegation.

### Needs Careful Refactor

List tasks that need more caution, deeper review, or smaller sequencing.

### Suggested ClickUp Tasks

Convert the strongest findings into task-sized items.

Use this format for each task:

#### `<task title>`

Scope:
- `<specific files/areas>`

Acceptance criteria:
- `<clear outcome>`
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- `<risk, sequencing, or follow-up notes>`

### Recommended First PR

End with the single best first PR to do, including:
- why it is first
- files likely touched
- verification expected