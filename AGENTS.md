# threed_print_cost_calculator

## Commands
- Setup: `fvm flutter pub get`
- Format: `fvm dart format .`
- Analyze: `fvm flutter analyze`
- Tests: `make flutter_test`
- Single test file: `fvm flutter test path/to_test.dart`
- Coverage: `./scripts/coverage.sh` (`lcov` required)
- Codegen: `make flutter_generate`
- Patrol release-gate E2E: `PATROL_FLUTTER_COMMAND="fvm flutter" patrol test --device emulator-5554 --no-uninstall`
- Optional legacy integration sweep: `fvm flutter test integration_test`

## Verify order
- Default: `fvm flutter analyze` -> `make flutter_test`
- If translations or generated code changed: run `make flutter_generate` before analyze/test
- If `intl_*.arb` changes but `lib/l10n/app_localizations.dart` does not, treat that as a broken sync and fix it before finishing
- If app-shell or premium/history flows changed: run relevant `integration_test/` or Patrol journey

## Architecture
- App startup: `lib/main.dart` initializes Firebase, App Check, Crashlytics, RevenueCat, Localizely, SharedPreferences, Sembast, migrations, then Riverpod overrides.
- Root widget: `lib/app/app.dart`. Main shell: `lib/app/app_page.dart`.
- Feature roots: `lib/calculator/`, `lib/history/`, `lib/settings/`, `lib/database/`, `lib/purchases/`, `lib/shared/`.
- `HistoryPage` exists only for premium users; `AppPage` dynamically removes that tab for free users.
- **Currency-agnostic**: All values are raw numbers. Do not show `$`, `€`, `£`, `¥`, or any currency symbol in labels, helpers, or UI surfaces.

## Testing quirks
- Widget tests should use `test/helpers/helpers.dart`; it installs mock SharedPreferences, in-memory Sembast, no-op analytics, and `AppLocalizations.localizationsDelegates`.
- Integration tests should use `integration_test/helpers/integration_test_harness.dart`; it seeds in-memory DB/prefs and fake purchases for free vs premium flows.
- Startup/migration behavior has dedicated coverage in `test/main_migration_test.dart`; keep migration order stable when touching bootstrap/database startup.
- Hidden in-app test overlays may use BotToast, but visible dialogs should stay in the project’s standard `AlertDialog`/Material style.

## Localisation
- Never leave user-facing copy hardcoded when the existing l10n system should be used.
- Source of truth for app strings: `lib/l10n/intl_*.arb`
- After any ARB change, run: `fvm flutter gen-l10n`
- Never manually edit generated localisation files.
- Use the project’s existing generated localisation access pattern consistently. Do not introduce a second localisation API in new code.
- If adding a new key, update the English ARB first, regenerate, then update all supported locale ARBs.
- Update all supported locales when adding or changing keys. Reuse existing wording patterns. Use placeholders instead of string concatenation.
- Audit every changed widget, dialog, banner, snackbar, and empty state for hardcoded user-facing text before merge.
- Keep developer-only strings out of l10n, including logs, debug messages, test descriptions, identifiers, analytics keys, and API field names, unless explicitly required.
- Sample or preview data may stay hardcoded when it is clearly demo content rather than product UI copy.
- Prefer passing localized strings into pure helpers rather than reading localisation state inside them.

## File Layout
- One widget per file. Keep each widget in its own Dart file, including helper sheets/dialogs/teaser states.
- If a file grows a second widget, split it before merging.
- Shared hidden test-tool widgets/services belong under `lib/shared/test_tools/`, not `lib/testing/`.

## Workflow notes
- Before broad exploration, read `docs/navigation.md`.
- Exploration budget before first plan: max 8 `Read`, 4 `Grep`, 2 `Bash` calls.
- Prefer targeted `rg`/content search over broad filesystem scans.
- Produce a short plan before code changes.
- MCP is optional and not the first step. Use `codebase-memory-mcp_search_graph` only after `docs/navigation.md`, mainly to confirm relationships or cross-feature links. Limit to 2 MCP queries unless clearly justified.
- Update docs when feature behavior, analytics/events, architecture, persistence, or app flows change.
- Prefer `docs/feature-map.md` for feature-level changes and `docs/architecture.md` for patterns, persistence, premium, localization, testing, and CI notes.

## Product planning and roadmap
- ClickUp is the lightweight operational roadmap: TLDR feature summaries, status, priority, dependencies, release targeting, and execution notes.
- Keep ClickUp task status in sync with implementation progress. Move tasks out of `to do` when work starts, and update them to the appropriate done/closed status when implementation is complete or deliberately cancelled.
- Repo docs are the implementation source of truth: specs, architecture, data models, edge cases, technical decisions, and agent instructions.
- Do not duplicate full implementation specs in ClickUp. Link ClickUp tasks to the relevant repo docs instead.
- When a repo doc is linked to a ClickUp task, include the ClickUp task ID in the doc metadata/header so agents can update the correct task without searching.
- Preferred doc metadata format: `ClickUp Task: <task_id>` near the top of the doc, under the title or summary.
- Keep LLM wiki/docs changes in repo so they remain versioned with code and reviewable in PRs.

## Changelog rules
- CHANGELOG.md is user-facing but more detailed than store notes
- Only include changes with user impact
- Keep structure consistent (Added, Changed, Fixed)
- New entries go at the top

## Documentation
- `docs/navigation.md` - Repo navigation map for agents before broad exploration.
- `docs/feature-map.md` - Feature-by-feature path map, state, services, models, and tests.
- `docs/architecture.md` - Current architecture, persistence, premium, localization, testing, and CI notes.
- `docs/README.md` - Documentation index
- `docs/gcode/` - G-code parser docs (overview, edge cases, slicer-specific docs, preview, test matrix)
- `docs/dev/patrol-ci.md` - Patrol E2E testing guide
- `docs/architecture/` - Architecture notes (e.g., performance)
- `docs/decisions/` - Architecture Decision Records (ADRs)
- `docs/product/` - Product specs and designs. Link from ClickUp tasks when a roadmap item has implementation detail.
- `docs/inbox/` - Work-in-progress notes before promotion into stable docs
