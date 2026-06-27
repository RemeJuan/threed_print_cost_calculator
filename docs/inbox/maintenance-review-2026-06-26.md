# Project Maintenance Review — 2026-06-26

> ClickUp Task: (pending)

Initial review was investigation-only. Progress updates below track maintenance PR work started from this review.

## Summary

1. `lib/history/history_page.dart`, `lib/batch_costing/batch_costing_page.dart`, `lib/purchases/paywall_screen.dart`, `lib/materials/widgets/materials_page.dart`, `lib/gcode_import/gcode_import_page.dart` carry too many responsibilities. Best maintenance ROI: split orchestration from subviews/actions/state helpers. No behavior change needed.
2. Strongest boundary leak: `lib/materials/widgets/materials_page.dart` does persistence, repository mutation, calculator cleanup, hint prefs inside widget. Good first cleanup target. Small, isolated, testable.
3. Architectural coupling risk: `lib/database/history_record_store.dart` mutates persistence and also invalidates `historyPagedProvider`. Storage knows UI paging state. Fragile over time.
4. `lib/settings/backup_restore/backup_restore_service.dart` mixes backup I/O, premium policy, DB clear/write, index rebuild. Important code, already tested, but hard to maintain safely.
5. `lib/shared/utils/csv_utils.dart` looks overloaded and partially duplicated. Split export/query/generation concerns before more features land there.
6. Test suite has some oversized files. Biggest value not "more tests everywhere"; value is focused gaps around materials delete/duplicate/hint persistence, history store invalidation, CSV import quota edge cases.
7. No analyzer errors. No obvious TODO/FIXME litter. Dead-code findings mostly low-confidence, not safe blind deletion.

---

## Findings

| File | Issue | Risk | Suggested cleanup | Effort |
| --- | --- | --- | --- | --- |
| `lib/materials/widgets/materials_page.dart` | Widget owns prefs, repo writes, delete/duplicate flows, calculator cleanup, toast orchestration | high | Extract page actions/controller helper for CRUD + swipe-hint persistence; keep widget focused on rendering | M |
| `lib/history/history_page.dart` | Screen mixes search, teaser/paywall, export flow, overflow-hint prefs/timer, infinite scroll | medium | Extract `history_page_body.dart`, overflow hint controller/helper, export flow helper | M |
| `lib/batch_costing/batch_costing_page.dart` | Page owns controller map sync, expanded-state sync, dialogs, premium gate, navigation | medium | Extract state-sync helper and action handlers; leave page as shell/composition | M |
| `lib/purchases/paywall_screen.dart` | RevenueCat fetch/purchase/restore plus layout and section builders in one class | medium | Split header/pitch/actions widgets or private files; isolate purchase/restore action handling | M |
| `lib/gcode_import/gcode_import_page.dart` | Single-file import, batch-mode gate, analytics, apply-to-calculator all mixed | medium | Extract single-flow vs multi-flow sections and action helper | M |
| `lib/settings/backup_restore/backup_restore_service.dart` | Service mixes file/share concerns, restore policy, DB clear/write, index rebuild | high | Split internal collaborators: payload parsing, premium-field merge, DB rewrite/index rebuild, file/export adapter | L |
| `lib/database/history_record_store.dart` | Persistence layer directly invalidates `historyPagedProvider` | high | Move stale-marking to higher-level coordinator/notifier or inject neutral callback boundary | M |
| `lib/shared/utils/csv_utils.dart` | Large mixed-purpose file; top-level helpers plus thin wrapper methods duplicate API | medium | Split pure CSV generation, file export, history query/export, batch export; remove thin wrappers after callsite audit | M |
| `lib/shared/test_tools/test_data_service.dart` | Raw store names duplicate index constants from history index files | low | Centralize store names in shared constants used by restore/test utilities | S |
| `lib/settings/backup_restore/backup_restore_service.dart` | Raw `'printer_index'` / `'history_search_index'` strings duplicated | low | Reuse shared constants from index/store definitions | S |
| `lib/materials/csv_import/csv_import_page.dart` | Quota check before import/save creates race window; likely under-tested | medium | Add focused tests first, then decide if sequencing helper needed | S |
| `test/materials/widgets/materials_page_test.dart` | Missing delete failure, duplicate save failure, swipe-hint persistence, calculator cleanup coverage | medium | Add focused widget tests by scenario | S |
| `test/app/view/app_page_test.dart` | Very large scenario matrix in one file | low | Split by theme: navigation, promo/premium, analytics | S |
| `test/gcode_import/gcode_import_page_test.dart` | Mixed analytics/rendering/flow cases in one file | low | Split by flow vs analytics vs preview | S |
| `test/batch_costing/batch_costing_page_test.dart` | Happy path, validation, premium gating, dialogs all in one file | low | Split by scenario groups | S |
| `test/settings/backup_restore/backup_restore_service_test.dart` | Strong coverage but very large and harder to extend safely | low | Split by export/restore/validation or by premium vs structural cases | M |
| `lib/shared/utils/csv_utils.dart` | Thin instance wrappers may be legacy pass-through API | low | Audit usages; collapse duplicate entry points if unused externally | S |
| `lib/materials/widgets/materials_page.dart` | Hardcoded preference key in widget | low | Move key + persistence helper out of UI file | S |

---

## Safe Quick Wins

- Split `MaterialsPage` action logic from widget tree.
- Centralize store-name constants for `'printer_index'` and `'history_search_index'`.
- Add materials-page tests for delete error, duplicate save failure, swipe hint persistence, calculator cleanup.
- Split oversized test files by scenario groups only. No behavior change.
- Extract history overflow-hint logic from `history_page.dart` into helper/controller file.
- Audit `CsvUtils` thin wrappers and document which entry points remain canonical.

## Needs Careful Refactor

- Decouple `HistoryRecordStore` from `historyPagedProvider`. Cross-layer dependency.
- Break up `BackupRestoreService` without weakening restore atomicity, premium-field preservation, or offline-first guarantees.
- Split `csv_utils.dart` carefully because export paths likely serve history and batch costing.
- Rework `gcode_import_page.dart` only after preserving premium multi-file gating and analytics ordering.
- Rework `paywall_screen.dart` without changing RevenueCat purchase/restore behavior or snackbar/error timing.

---

## Suggested ClickUp Tasks

### Extract materials page action logic from UI

Scope:
- `lib/materials/widgets/materials_page.dart`
- likely new helper under `lib/materials/widgets/` or `lib/materials/`

Acceptance criteria:
- delete, duplicate, swipe-hint persistence, calculator cleanup no longer implemented inline in page widget
- UI file primarily composes widgets and callbacks
- existing behavior unchanged for free/premium limits and toasts
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- best small PR
- keep repository and prefs usage out of widget where possible

---

### Add focused materials page regression tests

Scope:
- `test/materials/widgets/materials_page_test.dart`

Acceptance criteria:
- covers swipe-hint persistence path
- covers delete success and delete failure path
- covers calculator cleanup after delete
- covers duplicate save failure path
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- good companion PR or first safety-net PR before refactor

---

### Decouple history persistence from paging invalidation

Scope:
- `lib/database/history_record_store.dart`
- caller/notifier layer around history paging

Acceptance criteria:
- store no longer directly depends on `historyPagedProvider`
- history list still refreshes after insert/update/delete
- index maintenance remains intact
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- medium risk due refresh behavior
- sequence after adding tests around stale/invalidation behavior

---

### Split history page orchestration helpers

Scope:
- `lib/history/history_page.dart`
- possible new files under `lib/history/view/` or nearby

Acceptance criteria:
- overflow-hint prefs/timer logic extracted
- export flow logic extracted
- page shell easier to read, behavior unchanged
- premium teaser/full mode behavior preserved
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- lower risk than storage refactor
- existing page tests already decent safety net

---

### Break backup/restore service into internal collaborators

Scope:
- `lib/settings/backup_restore/backup_restore_service.dart`
- related tests in `test/settings/backup_restore/backup_restore_service_test.dart`

Acceptance criteria:
- payload parsing, premium-setting merge, DB clear/write, and file/export concerns separated internally
- restore remains atomic
- premium-only settings still preserved correctly for free users
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- important maintainability win
- high caution; keep PR small and internal-only

---

### Split csv utils by responsibility

Scope:
- `lib/shared/utils/csv_utils.dart`
- callsites in history/batch export features

Acceptance criteria:
- pure CSV generation separated from file/export/query responsibilities
- duplicate thin wrapper APIs removed or clearly deprecated internally
- export behavior unchanged
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- do usage audit first
- avoid churn if wrappers still needed by tests/mocks

---

### Add history store side-effect tests

Scope:
- tests around `lib/database/history_record_store.dart`

Acceptance criteria:
- covers insert/update/delete index sync
- covers paging invalidation behavior after mutations
- catches regression if index rebuild or stale marking breaks
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- do before decoupling store from paging provider

---

### Split oversized test files by scenario

Scope:
- `test/app/view/app_page_test.dart`
- `test/gcode_import/gcode_import_page_test.dart`
- `test/batch_costing/batch_costing_page_test.dart`
- `test/settings/settings_page_test.dart`
- optional `test/history/history_snapshot_regression_test.dart`

Acceptance criteria:
- scenario grouping clearer
- no assertion behavior changed
- shared fixtures stay readable
- `fvm flutter analyze` passes
- relevant focused tests pass

Notes:
- low risk
- useful parallel maintenance work

---

## Task Checklist

- [x] **PR 1 — Extract materials page action logic from UI** (`lib/materials/widgets/materials_page.dart`)
- [x] **PR 2 — Add focused materials page regression tests** (`test/materials/widgets/materials_page_test.dart`)
- [x] **PR 3 — Centralize store-name constants** (`'printer_index'`, `'history_search_index'` → shared constant)
- [x] **PR 4 — Add history store side-effect tests** (`lib/database/history_record_store.dart`)
- [x] **PR 5 — Decouple history persistence from paging invalidation** (follows PR 4)
- [x] **PR 6 — Split history page orchestration helpers** (`lib/history/history_page.dart`)
- [x] **PR 7 — Split oversized test files by scenario** (app, gcode_import, batch_costing, settings, optional history_snapshot deferred)
- [x] **PR 8 — Split csv utils by responsibility** (`lib/shared/utils/csv_utils.dart`)
- [x] **PR 9 — Extract gcode_import page sections** (`lib/gcode_import/gcode_import_page.dart`)
- [x] **PR 10 — Split paywall screen sections** (`lib/purchases/paywall_screen.dart`)
- [ ] **PR 11 — Break batch_cost page into helpers** (`lib/batch_costing/batch_costing_page.dart`)
- [ ] **PR 12 — Break backup/restore service into internal collaborators** (`lib/settings/backup_restore/backup_restore_service.dart`)

---

## Progress Log

### 2026-06-26 — Materials page action extraction

Status: committed.

Changed:
- Added `lib/materials/materials_page_actions.dart` for delete, duplicate, and swipe-hint persistence orchestration.
- Slimmed `lib/materials/widgets/materials_page.dart` so action callbacks delegate to `MaterialsPageActions`.
- Added focused `test/materials/widgets/materials_page_test.dart` coverage for swipe-hint persistence, delete success with calculator cleanup, and delete failure skipping calculator cleanup.

Verification:
- `fvm flutter test test/materials/widgets/materials_page_test.dart` passes.
- Dart analyzer on changed files passes.
- `fvm flutter analyze` passes.

Notes:
- This completes the recommended first PR scope and the focused materials regression-test companion scope.

---

### 2026-06-26 — History index store-name constants

Status: committed.

Changed:
- Added `lib/history/index/history_index_store_names.dart` for shared Sembast index store names.
- Updated history index helpers, backup/restore cleanup, test-data purge, and focused tests to use shared constants instead of raw store-name strings.

Verification:
- `fvm flutter test test/history/index/history_search_index_test.dart test/testing/test_data_service_test.dart test/settings/backup_restore/backup_restore_service_test.dart` passes.
- Dart analyzer on changed files passes.
- `fvm flutter analyze` passes.

Notes:
- This completes PR 3 scope and keeps restore/test utility cleanup aligned with index helper store names.

---

### 2026-06-26 — History store side-effect tests

Status: committed.

Changed:
- Extended `test/database/database_helpers_test.dart` to assert history insert updates both printer and search indexes while marking paged history stale.
- Extended history delete coverage to assert record deletion removes printer/search index entries and marks paged history stale after a fresh refresh baseline.
- Existing update coverage continues to assert printer/search index sync and stale marking after mutation.

Verification:
- `fvm flutter test test/database/database_helpers_test.dart` passes.
- Dart analyzer on changed test file passes.
- `fvm flutter analyze` passes.

Notes:
- This completes PR 4 safety-net scope before decoupling `HistoryRecordStore` from `historyPagedProvider` in PR 5.

---

### 2026-06-26 — History persistence decoupled from paging invalidation

Status: committed.

Changed:
- Removed the `historyPagedProvider` dependency from `lib/database/history_record_store.dart` so the store now only handles history persistence plus printer/search index maintenance.
- Moved history paged-state invalidation into `lib/database/database_helpers.dart` after successful history insert/update/delete operations.
- Extended `test/database/database_helpers_test.dart` with missing-key update/delete guards so paged history stays fresh when no history mutation actually occurs.

Verification:
- `fvm flutter test test/database/database_helpers_test.dart` passes.
- Dart analyzer on changed files passes.
- `fvm flutter analyze` passes.

Notes:
- This completes PR 5 scope while preserving the PR 4 stale-marking behavior contract at the helper boundary.

---

### 2026-06-26 — CSV utils split, PR 8 slice 1

Status: committed.

Changed:
- Added `lib/shared/utils/csv_generation.dart` with pure CSV helpers extracted from `csv_utils.dart`.
- Kept `lib/shared/utils/csv_utils.dart` provider, wrappers, file-export APIs, and export query flow intact; it now imports and re-exports the generation helpers.

Verification:
- `fvm flutter test test/shared/utils/csv_utils_test.dart` passes.
- `fvm flutter test test/history/history_snapshot_regression_test.dart` passes.
- `fvm flutter test test/history/view/history_page_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- First safe slice only. Provider/query/export service split still untouched.
- A batch-quote CSV column-count regression surfaced during extraction and was fixed before final verification.

---

### 2026-06-26 — CSV file export helpers, PR 8 slice 2

Status: committed.

Changed:
- Added `lib/shared/utils/csv_file_export.dart` with `writeCsvToFile` and `exportCSVFile` extracted from `lib/shared/utils/csv_utils.dart`.
- Updated `lib/shared/utils/csv_utils.dart` to import/export the new helper file while keeping `CsvUtils` wrapper methods and query/export service flow unchanged.

Verification:
- `fvm flutter test test/shared/utils/csv_utils_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Query/export service moved in slice 3.
- Public imports remain stable because `lib/shared/utils/csv_utils.dart` now re-exports `csv_file_export.dart`.

---

### 2026-06-26 — CSV history export service, PR 8 slice 3

Status: committed.

Changed:
- Added `lib/shared/utils/csv_history_export_service.dart` with `ExportRange`, `CsvUtils`, `csvUtilsProvider`, and history query/export methods moved out of `lib/shared/utils/csv_utils.dart`.
- Updated `lib/shared/utils/csv_utils.dart` into a compatibility facade that re-exports generation, file export, and service modules for callers.

Verification:
- `fvm flutter test test/shared/utils/csv_utils_test.dart` passes.
- `fvm flutter test test/history/history_snapshot_regression_test.dart` passes.
- `fvm flutter test test/history/view/history_page_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Public imports remain stable through `lib/shared/utils/csv_utils.dart`.
- `lib/shared/utils/csv_utils.dart` is now a facade-only compatibility export, so PR 8 acceptance is met.
- One initial validation attempt hit a transient Flutter build lock / macOS `install_name_tool` failure; rerun passed without code changes.

---

### 2026-06-27 — G-code import page sections, PR9 slice 1

Status: committed.

Changed:
- Added `lib/gcode_import/widgets/gcode_import_single_file_content.dart` for the single-file import body.
- Slimmed `lib/gcode_import/gcode_import_page.dart` to state, analytics, mode switching, and callbacks.

Verification:
- `fvm dart format lib/gcode_import/gcode_import_page.dart lib/gcode_import/widgets/gcode_import_single_file_content.dart` passes.
- `fvm flutter test test/gcode_import/gcode_import_page_rendering_test.dart test/gcode_import/gcode_import_page_preview_test.dart test/gcode_import/gcode_import_page_quantity_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Batch mode unchanged.
- Slice maps to commits `59f0c7b1` and `be7958eb`.

---

### 2026-06-27 — G-code import page actions, PR9 slice 2

Status: committed.

Changed:
- Added `lib/gcode_import/gcode_import_page_actions.dart` for error mapping and apply-flow orchestration.
- Slimmed `lib/gcode_import/gcode_import_page.dart` to state, analytics, mode switching, and callbacks.

Verification:
- `fvm dart format lib/gcode_import/gcode_import_page.dart lib/gcode_import/gcode_import_page_actions.dart lib/gcode_import/widgets/gcode_import_single_file_content.dart` passes.
- `fvm flutter test test/gcode_import/gcode_import_page_rendering_test.dart test/gcode_import/gcode_import_page_preview_test.dart test/gcode_import/gcode_import_page_quantity_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Batch mode unchanged.
- `lib/gcode_import/gcode_import_page.dart` is now shell-only for lifecycle analytics, file picking, and mode switching, so PR9 acceptance is met.
- Slice maps to commits `850d68f8` and `feafd316`.

---

### 2026-06-27 — Paywall screen presentational sections, PR 10 slice 1

Status: committed.

Changed:
- Added `lib/purchases/widgets/paywall_header.dart` for the close button header.
- Added `lib/purchases/widgets/paywall_pitch_section.dart` for title, pitch line, and subtitle.
- Added `lib/purchases/widgets/paywall_offering_error.dart` for the load-error message and retry action.
- Added `lib/purchases/widgets/paywall_bottom_bar.dart` for trust line, CTA, restore, and privacy/terms links.
- Slimmed `lib/purchases/paywall_screen.dart` to stateful orchestration plus composition of the new presentational widgets.

Verification:
- `fvm dart format lib/purchases/paywall_screen.dart lib/purchases/widgets/paywall_header.dart lib/purchases/widgets/paywall_pitch_section.dart lib/purchases/widgets/paywall_offering_error.dart lib/purchases/widgets/paywall_bottom_bar.dart` passes.
- `fvm flutter test test/purchases/paywall_screen_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Purchase/restore orchestration still inline by design for this first slice.

---

### 2026-06-27 — Paywall screen action extraction, PR 10 slice 2

Status: committed.

Changed:
- Added `lib/purchases/paywall_screen_actions.dart` for paywall offering load, purchase, restore, and snackbar/log orchestration.
- Updated `lib/purchases/paywall_screen.dart` so async methods delegate gateway, analytics, and logger work to the new helper.

Verification:
- `fvm dart format lib/purchases/paywall_screen.dart lib/purchases/paywall_screen_actions.dart` passes.
- `fvm flutter test test/purchases/paywall_screen_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- Purchase/restore orchestration moved out of the widget methods, but state remains in `PaywallScreen` by design.
- `lib/purchases/paywall_screen.dart` now reads as state/wiring shell plus composed sections, so PR 10 acceptance is met.
- Slices map to commit `a4486fc5` plus this documentation commit.

---

### 2026-06-26 — History page orchestration helpers

Status: committed.

Changed:
- Extracted `lib/history/hooks/history_overflow_hint.dart` so overflow-hint prefs, timer cleanup, and analytics no longer live inline in `lib/history/history_page.dart`.
- Extracted `lib/history/hooks/history_page_actions.dart` for export-sheet, history export, teaser preview, and teaser paywall orchestration.
- Slimmed `lib/history/history_page.dart` into page composition that wires the new hook/actions helpers into teaser and full-history modes.

Verification:
- `fvm flutter test test/history/view/history_page_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- This completes PR 6 scope while preserving the existing overflow-hint, export, and teaser/premium widget-test behavior.

---

### 2026-06-26 — Settings page test split by scenario

Status: committed.

Changed:
- Split `test/settings/settings_page_test.dart` into `test/settings/settings_page_free_access_test.dart` and `test/settings/settings_page_premium_actions_test.dart` so free-access coverage and premium-action coverage live in separate scenario files.
- Added `test/settings/settings_page_test_support.dart` for shared `FakeSettingsRepository` and no-op log sink fixtures.
- Kept assertions and test bodies aligned with prior settings-page coverage; only file organization changed.

Verification:
- `fvm flutter test test/settings/settings_page_free_access_test.dart test/settings/settings_page_premium_actions_test.dart` passes.

Notes:
- This starts PR 7 with the lowest-risk oversized test split before touching larger app, gcode import, or batch-costing files.

---

### 2026-06-26 — App page test split by scenario

Status: committed.

Changed:
- Split oversized `test/app/view/app_page_test.dart` into scenario files: `test/app/view/app_page_navigation_test.dart`, `test/app/view/app_page_app_bar_test.dart`, `test/app/view/app_page_selection_test.dart`, and `test/app/view/app_page_startup_test.dart`.
- Extended `test/app/view/app_page_test_support.dart` with shared fake analytics and whats-new fixture support used across the new scenario files.
- Kept existing assertions and flow coverage aligned while grouping navigation, app-bar, selection/history promo, and startup/support scenarios into smaller files.

Verification:
- `fvm flutter test test/app/view/app_page_navigation_test.dart test/app/view/app_page_app_bar_test.dart test/app/view/app_page_selection_test.dart test/app/view/app_page_startup_test.dart` passes.

Notes:
- This continues PR 7 by splitting the largest app-shell widget test into reviewable scenario files without touching production code.

---

### 2026-06-26 — G-code import test split by scenario

Status: committed.

Changed:
- Split `test/gcode_import/gcode_import_page_test.dart` into `test/gcode_import/gcode_import_page_rendering_test.dart`, `test/gcode_import/gcode_import_page_preview_test.dart`, and `test/gcode_import/gcode_import_page_quantity_test.dart`.
- Added `test/gcode_import/gcode_import_page_test_support.dart` for shared controller, picker, service, analytics, and sample-result fakes.
- Preserved the existing analytics, preview rendering, no-preview, quantity, and batch-flow assertions; only file organization changed.

Verification:
- `fvm flutter test test/gcode_import` passes.
- `fvm flutter analyze` passes.

Notes:
- Focused on test-only churn. No production code touched.
- `test/history/history_snapshot_regression_test.dart` remains optional PR 7 follow-up if it becomes difficult to extend.

---

### 2026-06-26 — Batch costing test split by scenario

Status: committed.

Changed:
- Split `test/batch_costing/batch_costing_page_test.dart` into `test/batch_costing/batch_costing_page_review_test.dart` and `test/batch_costing/batch_costing_page_manual_item_test.dart`.
- Added `test/batch_costing/batch_costing_page_test_support.dart` for the shared batch-flow home harness and fake batch costing notifier.
- Preserved review/remove/import-gate/start-new-batch, manual CRUD, validation, defaults, and quota assertions; only file organization changed.

Verification:
- `fvm flutter test test/batch_costing/batch_costing_page_review_test.dart test/batch_costing/batch_costing_page_manual_item_test.dart` passes.
- `fvm flutter analyze` passes.

Notes:
- This completes the required PR 7 oversized-test split targets; optional history snapshot split is deferred because the main app, G-code import, batch costing, and settings files are now scenario-grouped.

---

## Recommended First PR

**Extract materials page action logic from UI**

Why first:
- strongest UI/domain leak
- isolated feature surface
- small enough for review
- immediate readability gain
- good pattern for later screens (`history`, `gcode_import`, `batch_costing`)

Files likely touched:
- `lib/materials/widgets/materials_page.dart`
- new helper file for actions/persistence, likely under `lib/materials/widgets/` or `lib/materials/`
- `test/materials/widgets/materials_page_test.dart`

Verification expected:
- `fvm flutter analyze`
- focused materials widget tests
- manual sanity: delete, duplicate, swipe hint dismiss, free-tier limits unchanged
