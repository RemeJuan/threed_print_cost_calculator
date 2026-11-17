# Maintenance Review Execution Plan

Status: Complete
Scope: Behavior-preserving maintenance unless a task explicitly identifies a bug fix.
ClickUp: Not used; this file is the local task list.

## Workflow

- Complete tasks in listed order. Only one task may be active at a time.
- For each task, implement the scoped change, then run `fvm flutter analyze` and the listed focused tests.
- After implementation and checks, execute the OpenCode `/claude-review` slash command.
- Address review findings. If code changes, rerun relevant checks and `/claude-review`.
- Mark task `[x]` only after checks pass and review findings are resolved. Record test results and review outcome in task notes.
- Run `make flutter_test` before merging each implementation PR.

## Tasks

### 1. [x] Extract CSV import presentation

**Scope:** Extract review and result presentation from `lib/materials/csv_import/csv_import_page.dart`. Keep file picking, premium checks, import persistence, analytics, and state transitions in the page.

**Acceptance:** Existing keys, localization, layout, and flow remain unchanged. CSV import tests pass.

**Verify:** `fvm flutter analyze`; `fvm flutter test test/materials/csv_import/csv_import_page_test.dart`.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Extracted review/result widgets into `lib/materials/csv_import/csv_import_presentation.dart`; page retains file picking, premium gating, persistence, analytics, and state.
- `fvm flutter analyze` passed; `fvm flutter test test/materials/csv_import/csv_import_page_test.dart` passed (7 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; review reran focused tests and analysis successfully.
- DTD connected but no running app registered, so hot reload unavailable.

### 2. [x] Characterize work-cost persistence

**Scope:** Extend `test/settings/work_costs_form_test.dart` to cover debounce replacement, invalid input, external settings updates, disposal, and persistence failures. Do not change behavior in this task.

**Acceptance:** Existing behavior is documented by focused tests; any needed behavior fixes are recorded as separate follow-up tasks.

**Verify:** `fvm flutter analyze`; `fvm flutter test test/settings/work_costs_form_test.dart`.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Added tests for debounce replacement, external settings updates, disposal, and persistence failure; existing invalid-input coverage retained. No production behavior changed.
- `fvm flutter analyze` passed; `fvm flutter test test/settings/work_costs_form_test.dart` passed (14 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; review reran focused tests and analysis successfully.

### 3. [x] Handle G-code validation read failures

**Scope:** Cover exceptions during size/sniff validation in `parsePickedFile`; map validation read errors to the appropriate failure state without allowing stale attempts to overwrite newer results.

**Acceptance:** Failure classification and telemetry behavior are explicit; controller failure and overlap regression tests pass.

**Verify:** `fvm flutter analyze`; focused G-code controller failure and overlap tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Validation size/sniff exceptions now map to `readFailed` with capture, breadcrumb, analytics, and failure state; stale attempts cannot report or overwrite newer results.
- `fvm flutter analyze` passed; focused controller failure and overlap tests passed (13 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; targeted analysis and 27 combined focused tests passed.

### 4. [x] Reuse no-path G-code input bytes

**Scope:** Avoid repeated callback-backed reads across size resolution, sniff validation, and parsing. Preserve the 50 MB limit, parser semantics, and path-backed streaming.

**Acceptance:** Tests prove intended read count and oversized-input behavior; no-path and path-backed flows remain covered.

**Verify:** `fvm flutter analyze`; focused G-code validator, service, and controller tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Memoized callback-backed no-path bytes across size resolution, sniff validation, and parsing; preserved metadata size rejection before reading and path-backed streaming.
- `fvm flutter analyze` passed; focused validator, service, and controller tests passed (53 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; review ran 70 combined focused tests successfully. Existing unknown-size callback memory behavior deferred, not introduced here.

### 5. [x] Establish history-index invariants

**Scope:** Add tests for numeric-string versus integer keys, rebuild/mutation interleavings, and unusually long tokens. Keep any index redesign separate.

**Acceptance:** Correctness and performance characteristics are recorded; discovered defects become separately scoped tasks.

**Verify:** `fvm flutter analyze`; focused history index and paging tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Added numeric-string/integer key, update-during-rebuild, and long-token indexing tests. Existing insert-during-rebuild coverage retained; no production behavior changed.
- Numeric-string `123` and integer `123` currently collapse to integer key; 104-character repeated-alphabet token yields 2,379 unique indexed substrings. Follow-up defects scoped below.
- `fvm flutter analyze` passed; focused history index and paging tests passed (29 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable regressions; review reran analysis and 81 combined focused tests successfully.

### 6. [x] Separate calculator save orchestration

**Scope:** Move premium/history/stock/UI side effects out of `lib/calculator/helpers/calculator_helpers.dart`, preserving successful-save ordering and user-visible outcomes.

**Acceptance:** Quota handling, failed-save behavior, stock deduction order, and messages remain unchanged.

**Verify:** `fvm flutter analyze`; focused calculator helper, save-form, and history persistence tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Extracted save flow into `lib/calculator/services/calculator_save_coordinator.dart`; SaveForm uses coordinator while generic calculator helpers no longer own premium/history/stock/UI effects. Updated test fakes and history regression overrides.
- Added quota/paywall recount, ordering, failure, and localized-message assertions. `fvm flutter analyze` passed; focused calculator helper/save-form/history persistence and history tests passed (122 tests).
- Initial OpenCode `/claude-review` found stale history test override; fixed it, reran analysis and focused tests, then reran `/claude-review` via `opencode run --command claude-review` with no actionable findings. Final review ran 91 combined focused tests successfully.

### 7. [x] Move history invalidation ownership

**Scope:** Remove the direct `historyPagedProvider` dependency from generic database helpers through a clear history-layer boundary.

**Acceptance:** History insert/update/delete still invalidate paging; unrelated database writes remain unaffected.

**Verify:** `fvm flutter analyze`; focused database helper and history paging tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Added `lib/history/history_mutation_boundary.dart` for transactional history mutations and paging invalidation; generic database helpers no longer depend on history paging. History save and delete callers use boundary; successful delete refreshes mounted paging immediately, while insert/update mark it stale.
- `fvm flutter analyze` passed; focused database helper, history paging, and history item action tests passed (33 tests), including unrelated-write and immediate-delete assertions.
- Initial OpenCode `/claude-review` identified missing visible-list refresh on delete; fixed it, reran checks, then reran `/claude-review` via `opencode run --command claude-review` with no actionable findings. Final review reran analysis and 108 focused tests successfully.
### 8. [x] Characterize calculator async lifecycle

**Scope:** Test overlapping initialization/reset/history-load operations and disposal during awaits before deciding whether generation guards or other changes are required.

**Acceptance:** Intended lifecycle behavior is recorded; any behavior fix is separately scoped.

**Verify:** `fvm flutter analyze`; focused calculator initialization and history-load tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Added deterministic gated tests for init/reset and overlapping history loads, plus disposal during an awaited history load. No production behavior changed.
- Earlier init completing after reset overwrites reset state; earlier history load completing after a newer load overwrites newer state. In-flight history load after provider disposal throws a Riverpod unmounted-Ref error. Follow-up fixes scoped below.
- `fvm flutter analyze` passed; focused initialization and history-load tests passed (21 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; review reran analysis and 113 valid focused tests successfully.

### 9. [x] Characterize premium storage failures

**Scope:** Test preload/write/delete failures and disposal during override cleanup. Preserve documented in-memory fallback behavior.

**Acceptance:** Failure and retry semantics are explicit; behavior changes are separately scoped.

**Verify:** `fvm flutter analyze`; focused premium notifier and local-store tests.

**Review:** Run the OpenCode `/claude-review` slash command after implementation and verification.

**Notes / results:**

- Added cached-store preload, write, and delete failure tests: errors report through `onError` without discarding prior in-memory values. Added expired-override cleanup failure and disposal-during-cleanup tests; free fallback persists, while cleanup failure currently escapes as an unhandled asynchronous error. No production behavior changed.
- `fvm flutter analyze` passed; focused premium notifier and local-store tests passed (17 tests).
- OpenCode `/claude-review` via `opencode run --command claude-review`: no actionable findings; review reran analysis and 157 focused tests successfully.
- Final full suite: `make flutter_test` passed (1,019 passed, 2 skipped); `git diff --check` clean. No running Flutter app was connected for hot reload.

## Deferred decisions

- Follow-up: handle expired-override cleanup failures without unhandled asynchronous errors; specify retry policy and preserve free in-memory fallback and disposal behavior.
- Follow-up: define and enforce generation/precedence rules for overlapping calculator init, reset, and history loads so stale completions cannot replace newer state; retain cancellation and user-visible outcomes.
- Follow-up: guard in-flight calculator history load completion and error logging after provider disposal; decide cancellation/error contract and test it.
- Follow-up: fix numeric-string/integer history key collision without changing persisted key identity or paging unexpectedly; first specify migration and lookup compatibility.
- Follow-up: assess and bound long-token substring indexing cost with representative data and an explicit search-quality/performance trade-off before redesign.
- Decide whether to extract shared work-cost persistence only after task 2 establishes current behavior.
- Decide whether to split or optimize history indexing only after task 5 establishes invariants and costs.
- Confirm product rule for material-ID uniqueness during edits before enforcing it.
- Do not remove suspected stale code without reference and lifecycle evidence.
- Preserve existing currency settings behavior; do not add currency symbols to UI copy.
