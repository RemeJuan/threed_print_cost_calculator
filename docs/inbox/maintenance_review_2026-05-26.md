# Maintenance Review — 2026-05-26

## Summary
Repo shape mostly healthy. Biggest maintenance debt not raw LOC alone. Real risk cluster is UI-heavy files that also own persistence, analytics, parsing, and error handling.

Highest-value targets:
1. `lib/materials/csv_import/csv_import_page.dart`
2. `lib/settings/work_costs_form.dart`
3. `lib/gcode_import/gcode_import_controller.dart`

Why:
- crowded responsibilities
- weaker or missing failure-path tests
- direct runtime logging / ad hoc error handling
- harder to review safely than domain-pure large files

Lower urgency than size suggests:
- `lib/core/analytics/app_analytics.dart`
- `lib/gcode_import/gcode_import_parser.dart`
- `lib/history/history_page.dart`

Reason: stronger direct tests or tighter domain cohesion.

## Task List

- [x] **1. CSV import page split + coverage** — extract parsing/validation from `csv_import_page.dart`, add failure-path tests *(done before 2026-05-26 session)*
- [x] **2. Work costs form persistence cleanup** — deduplicate `persistX` pattern in `work_costs_form.dart`, add logging tests *(done before 2026-05-26 session)*
- [x] **3. G-code import controller split + failure tests** — separate validation/sniffing from controller, cover service exceptions *(done before 2026-05-26 session)*
- [x] **4. Batch quote save flow hardening** — test `batch_quote_save_service`, replace `debugPrint` *(done 2026-05-26)*
- [x] **5. Batch G-code import handler tests** — cover duplicates, mixed outcomes, single-file errors *(done 2026-05-26)*
- [x] **6. History search index performance guardrail** — test verifies substring expansion bounded by N*(N+1)/2 per token *(done 2026-05-26)*
- [x] **7. Observability cleanup for helpers** — normalize `debugPrint` across indexers/launchers *(done 2026-05-26)*

## Findings

| File | Issue | Risk | Suggested cleanup | Effort |
| --- | --- | --- | --- | --- |
| `lib/materials/csv_import/csv_import_page.dart:42-248,305-406` | One screen owns template sharing, file picking, CSV tokenizing, row parsing, validation, repository writes, preview rendering, row model. | Highest maintainability risk. Sparse tests mean regressions can hide in import/failure flows. | Extract pure CSV parse/validate helper and import executor service. Keep page as orchestration + rendering only. | M |
| `test/materials/csv_import/csv_import_page_test.dart` | Only covers intro/buttons. No success, failure, malformed CSV, partial-row, repository-error, template-share tests. | Weakest coverage among hotspots. | Add focused tests around parser output, invalid rows, per-row repository failure, success counts. | M |
| `lib/materials/csv_import/csv_import_page.dart:225-235` | Row import failures use `debugPrint` instead of app logging abstraction. | Runtime diagnostics inconsistent; hard to track production issues. | Route through shared logger or structured failure callback. | S |
| `lib/settings/work_costs_form.dart:66-189,191-216,337-377,409-518` | Widget owns six controllers, six debounce timers, repeated `persistX` closures, direct settings writes, inline controller mutation, analytics from callbacks. | Strongest UI/business boundary leak. Hard to change safely. | Extract small persistence helpers/controller object for parse-save-log-debounce pattern. Keep widget callbacks thin. | M |
| `test/settings/work_costs_form_test.dart` | Good debounce coverage, but no explicit error-path or analytics verification. | Refactor can preserve happy path but still miss logging/error regressions. | Add tests for service failure, invalid persisted state sync, analytics trigger conditions. | S-M |
| `lib/gcode_import/gcode_import_controller.dart:28-200,210-361` | `parsePickedFile` mixes analytics, breadcrumbs, size checks, validation, service call, error mapping, state changes. Same file also holds sniffing/validation/state types. | Moderate maintenance risk. Failure handling hard to reason about. | Split file validation/sniffing into dedicated helper, keep controller focused on state orchestration. | M |
| `test/gcode_import/gcode_import_controller_test.dart` | Covers acceptance and oversize checks, not service exception path, empty-metadata path, analytics/breadcrumb side effects. | Hidden regressions in rare but important failure flows. | Add failure-path tests before or during split. | S |
| `lib/history/index/history_search_index.dart:84-97,169-213` | `_tokensWithSubstrings` builds every substring for each token. `rebuildIndex` rewrites full index from store. | Performance/space growth with larger history sets. Behavior-sensitive, not urgent correctness bug. | Document constraints, add micro-benchmark or targeted perf test, then consider narrowing index strategy. | M |
| `lib/history/index/history_search_index.dart:111-124` | Malformed-record path uses `debugPrint`. | Low correctness risk, medium observability debt. | Use shared logger or guarded diagnostics helper. | S |
| `test/history/index/history_search_index_test.dart` | Good semantic coverage, no performance guardrails. | Future "cleanup" can accidentally make index cost worse or semantics drift. | Add lightweight perf-oriented test or dataset-size note in docs/comments. | S |
| `lib/batch_costing/helpers/batch_quote_save_service.dart:18-135` | Helper mixes dialog flow, history persistence, analytics, toast, and navigation. No direct tests found. Uses `debugPrint` on save failure at `:61`. | Medium risk. Save flow touches persistence + UX + analytics in one function. | Extract persistence/analytics result helper, add widget/service tests for success/failure branches. | M |
| `lib/batch_costing/providers/batch_gcode_import_handler.dart:134-318` | Multi-file import flow manages picker, duplicate filtering, UI state, service calls, notifier writes, analytics, error rendering. No direct tests found. | Medium risk adjacent to already-tested notifier. Likely better ROI than deeper notifier refactor. | Add targeted tests for duplicates, mixed ready/needs-details/failed rows, single-file error path. | M |
| `lib/history/index/printer_index.dart:45-50,57-90,169-189` | Full rebuild + substring match over all indexed printers; malformed records use `debugPrint`. Tests exist, but only basic happy paths. | Low-medium risk now, scales similarly to history index. | Keep as secondary cleanup after higher-value work. Add malformed-record test if touched. | S-M |
| `lib/shared/providers/update_checker_provider.dart:46-61,73-180` | Provider has launch + cooldown + platform/store availability logic. No direct tests found. Uses `debugPrint` if store launch fails. | Low immediate debt, but async/provider behavior unpinned. | Add small provider/unit tests if update prompt behavior changes later. | S |
| `lib/app/help_support/help_support_links.dart:16-24` | `openUrl` silently returns on parse failure and uses `debugPrint` on launch failure. No direct helper tests; only indirect UI coverage. | Low risk. Small reliability/observability debt. | Optional tiny unit test around launcher fallback if helper changes later. | S |
| `lib/core/analytics/app_analytics.dart` | Very large file, many event wrappers. | Size alone noisy here; direct tests are broad. | Only split by event domain if active development pain appears. Not first-pass refactor. | M-L |
| `lib/gcode_import/gcode_import_parser.dart` | Large parser and streaming state in one file. | Moderate refactor risk but domain logic well covered. | Leave until higher-ROI UI-heavy cleanups land. | L |

## Safe Quick Wins
- Replace app-runtime `debugPrint` in user-flow code with shared logging policy:
  - `lib/materials/csv_import/csv_import_page.dart`
  - `lib/batch_costing/helpers/batch_quote_save_service.dart`
  - `lib/history/index/history_search_index.dart`
  - `lib/history/index/printer_index.dart`
  - `lib/app/help_support/help_support_links.dart`
  - `lib/shared/providers/update_checker_provider.dart`
- Add missing failure-path tests before structural refactors:
  - CSV import repository failure
  - G-code import service exception
  - batch quote save failure
- Extract pure helpers first, not widget trees:
  - CSV row parsing
  - work-cost field persist/debounce logic
  - G-code file sniffing/validation

## Needs Careful Refactor
- `lib/settings/work_costs_form.dart`
  - behavior pinned by tests, but controller/focus/timer lifecycle easy to break
- `lib/gcode_import/gcode_import_controller.dart`
  - many side effects in one method; split order matters
- `lib/history/index/history_search_index.dart`
  - performance issue real, but semantics already tested and likely user-visible if changed
- `lib/gcode_import/gcode_import_parser.dart`
  - deterministic core logic; churn risk higher than payoff right now

## Suggested ClickUp Tasks

### 1. CSV import page split + coverage
**Scope:** extract CSV parsing/validation/import helpers from `lib/materials/csv_import/csv_import_page.dart`; add tests for malformed rows, per-row save failure, successful import counts, template/share path if practical.

**Acceptance:**
- page no longer owns raw CSV parsing and repository loop
- no `debugPrint` in import failure path
- tests cover success and failure flows, not only intro UI

**Notes:** strongest first candidate; safest payoff.

### 2. Work costs form persistence cleanup
**Scope:** extract repeated parse-save-log-debounce logic from `lib/settings/work_costs_form.dart` into reusable helper/controller without changing UX.

**Acceptance:**
- duplicate `persistX` closure pattern reduced substantially
- widget callbacks thinner
- existing tests still pass
- add at least one failure-path/logging test

**Notes:** boundary cleanup, not redesign.

### 3. G-code import controller split + failure tests
**Scope:** separate validation/sniffing/state types from `lib/gcode_import/gcode_import_controller.dart`; add exception and empty-result tests.

**Acceptance:**
- controller file smaller and focused on orchestration
- validation/sniffing isolated in pure helper/module
- tests cover service exception and metadata-empty failure path

**Notes:** moderate risk, good second/third PR.

### 4. Batch quote save flow hardening
**Scope:** cover `saveBatchQuote` success/failure branches and remove direct `debugPrint`.

**Acceptance:**
- direct tests for persistence failure and success navigation intent
- structured logging used on failure

**Notes:** small-medium task; good standalone cleanup.

### 5. Batch G-code import handler tests
**Scope:** add direct tests for duplicate filtering, mixed row outcomes, single-file failure messaging.

**Acceptance:**
- handler behavior covered beyond notifier tests
- ready / needs-details / failed counts asserted

**Notes:** likely better ROI than notifier refactor.

### 6. History search index performance guardrail
**Scope:** measure/document substring index growth and add safety coverage before algorithm changes.

**Acceptance:**
- perf note, benchmark, or constrained test added
- no search semantics change

**Notes:** do after UI-heavy debt.

### 7. Observability cleanup for helper launches/indexers
**Scope:** normalize helper-level logging in `help_support_links`, `update_checker_provider`, `printer_index`, `history_search_index`.

**Acceptance:**
- no user-flow `debugPrint` outside deliberate low-level logger boundary

**Notes:** small hygiene bundle.

## Recommended First PR
**CSV import page split + coverage**

**Why:** best mix of payoff and safety — weakest current tests, highest responsibility density in one screen, direct runtime `debugPrint` already marks rough edges, extraction can be behavior-preserving and reviewable.

**Files:**
- `lib/materials/csv_import/csv_import_page.dart`
- likely new helper(s) beside it for CSV parse/validate/import
- `test/materials/csv_import/csv_import_page_test.dart`
- maybe dedicated pure-helper tests if extraction goes there

**Verification:**
- existing CSV import widget tests pass
- new tests for malformed rows, partial validation, repository failure, success summary
- `fvm flutter analyze`
- targeted `fvm flutter test test/materials/csv_import/csv_import_page_test.dart`
