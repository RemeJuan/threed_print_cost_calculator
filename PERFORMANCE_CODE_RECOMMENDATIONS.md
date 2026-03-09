# Performance and Code Enhancement Recommendations

## Evaluation scope

This review is based on a static pass over the Flutter/Riverpod/Sembast codebase, with emphasis on:

- calculator state management and write paths
- history search/pagination behavior
- data access patterns
- UI rebuild and event handling behavior
- reliability and maintainability opportunities that also affect runtime performance

> Note: runtime profiling commands (`flutter analyze`, `flutter test`, DevTools traces) could not be executed in this environment because `fvm` and `flutter` are not installed.

---

## High-impact performance recommendations

### 1) Remove N+1 database fetches in history indexed search
**Where:** `lib/history/provider/history_paged_notifier.dart`

When query text matches the printer index, code gets matching keys and then performs one DB lookup per key:

- `getKeysMatchingPrinter(q)`
- loop over keys
- `await _store.record(k).get(_db)` for each key

This creates an N+1 pattern and can become noticeably slow as history grows.

**Recommendation**
- Fetch indexed records in batches where possible, or redesign the index to store minimal sortable metadata (date + key) to avoid separate record reads.
- If Sembast batch APIs are limited for this flow, run key fetches concurrently with bounded parallelism.

**Expected impact:** faster search response and reduced I/O overhead on larger datasets.

---

### 2) Avoid full-table scan fallback for non-index hits
**Where:** `lib/history/provider/history_paged_notifier.dart`

If no printer-index matches are found, code loads all history rows and filters in memory by `name` and `printer`.

**Recommendation**
- Add a normalized search index for both `name` and `printer`.
- Persist searchable lowercase tokens at write time so reads can stay index-driven.
- If full-text indexing is not feasible, cap fallback scan with a warning banner + user hint.

**Expected impact:** scalable query performance and lower memory pressure.

---

### 3) Collapse repeated state updates in material weight normalization
**Where:** `lib/calculator/provider/calculator_notifier.dart` (`applySingleTotalWeightToFirstRow`)

The method iterates through material rows and calls `updateMaterialUsageWeight` multiple times. Each call recomputes totals and emits state changes.

**Recommendation**
- Build the fully updated material list in memory once.
- Compute total weight once.
- Emit a single `state = state.copyWith(...)` update.

**Expected impact:** fewer provider notifications/rebuilds and smoother UI interaction when many material rows exist.

---

## Medium-impact enhancements

### 4) Normalize numeric parsing through a shared utility
**Where:** calculator/settings/history input parsing paths

The code frequently uses variants of `.replaceAll(',', '.')` + `num.tryParse(...)` in multiple methods.

**Recommendation**
- Introduce a dedicated numeric parser utility (e.g., `parseLocalizedNum(String input)`).
- Centralize trimming/comma-decimal conversion/default handling.

**Expected impact:** less duplicated logic, fewer subtle parsing inconsistencies, easier testing.

---

### 5) Defer expensive refresh if state is already initialized
**Where:** `lib/history/history_page.dart`

`HistoryPage` triggers an initial `refresh()` after first frame every time the page mounts. In some navigation patterns this may repeatedly re-fetch page 1 even when data is already available.

**Recommendation**
- Guard initial refresh: only refresh when cached `items` is empty or stale.
- Consider keeping the provider alive and add an explicit refresh action for users.

**Expected impact:** reduced redundant I/O and quicker return-to-page experience.

---

### 6) Strengthen data typing at DB boundaries
**Where:** `history_paged_notifier.dart`, calculator DB reads

There are several `Map` casts and dynamic conversions (`Map<String, dynamic>.from(...)`, `as Map`).

**Recommendation**
- Standardize typed repository methods for each store (`history`, `settings`, `materials`, etc.).
- Keep model conversion in one layer.

**Expected impact:** lower runtime cast risk, cleaner code paths, easier optimization.

---

## Code quality and maintainability improvements

### 7) Replace debug `print` with structured logging hooks
**Where:** `calculator_notifier.dart`, `history_paged_notifier.dart`

Current error paths use `print(...)` under `kDebugMode`.

**Recommendation**
- Introduce a lightweight logger abstraction with categories (`db`, `provider`, `ui`).
- Route severe errors to analytics/crash reporting (without PII).

**Expected impact:** better observability and easier field debugging.

---

### 8) Add focused performance regression tests
**Where:** `test/history`, `test/calculator`

Existing tests cover functionality well, but there is no explicit guardrail against performance regressions in pagination/search/state updates.

**Recommendation**
- Add tests that assert bounded DB call counts for typical query scenarios.
- Add micro-bench-like tests around material update flows (e.g., many rows update should emit minimal state transitions).

**Expected impact:** prevents accidental reintroduction of expensive code paths.

---

## Suggested implementation order

1. **History query optimization** (Recommendations 1 + 2).
2. **Single-emission state update for material normalization** (Recommendation 3).
3. **Shared numeric parser + typed DB repository boundaries** (Recommendations 4 + 6).
4. **Refresh guard and logging improvements** (Recommendations 5 + 7).
5. **Performance-focused tests** (Recommendation 8).

---

## Success criteria to track

- Median history query latency (empty query and non-empty query).
- Time-to-first-item in History page.
- Number of DB reads per paged search request.
- Number of provider state emissions for “apply single total weight”.
- Jank/frame time while typing in search and editing materials.

