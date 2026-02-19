Plan: History filtering + toolbar extraction

Goal

- Add a single free-text search field to the History page that filters history records by `name` and `printer` (
  case-insensitive).
- Extract the top toolbar (search + export) into a reusable sub-widget.
- Debounce user input (300ms) to avoid re-filtering on every keystroke.
- Move filtering logic into a Riverpod provider, and add unit tests using an in-memory Sembast database.

Checklist

1. UI
    - [ ] Create `HistoryToolbar` sub-widget that contains:
        - TextField for free-text search with clear button
        - Export button that opens the existing export sheet
    - [ ] Replace inline toolbar in `HistoryPage` with `HistoryToolbar`.

2. Debounce
    - [ ] Add a 300ms debounce to the search TextEditingController to avoid immediate updates.
    - [ ] Ensure Timer is cancelled on dispose.

3. Provider
    - [ ] Create `historyQueryProvider` (NotifierProvider<String>) to hold the current query.
    - [ ] Create `historyRecordsProvider` (FutureProvider.autoDispose<List<RecordSnapshot>>) that reads the Sembast DB
      and filters in-memory by `name` and `printer`.
    - [ ] Update `HistoryPage` to watch `historyRecordsProvider` and use the provider-driven filtered list.

4. Tests
    - [ ] Add unit tests in `test/history/provider/history_providers_test.dart`:
        - Use `sembast_memory` to create an in-memory Sembast DB and insert sample records.
        - Override `databaseProvider` in a ProviderContainer to point at the test DB.
        - Assert: provider returns all records for empty query.
        - Assert: provider filters by name and printer (case-insensitive).

5. Quality gates
    - [ ] Run static analysis / error checks on changed files.
    - [ ] Run the new unit tests.

Implementation notes

- Use `hooks_riverpod` / `riverpod` NotifierProvider pattern consistent with the repo rather than legacy `StateProvider`
  usage.
- Keep filtering in-memory for now to avoid Sembast string/date query edge cases. If database growth becomes a problem,
  refactor to use indexed fields or server-side search.
- The debounce updates the notifier state after 300ms; UI TextField remains responsive and shows current input
  immediately.
- `historyRecordsProvider` is autoDispose to free resources when the page is not mounted.

Acceptance criteria

- Search box filters the visible history items by `name` and `printer` with case-insensitive substring matching.
- The toolbar is in a separate file and re-usable.
- No static errors are introduced.
- Unit tests for `historyRecordsProvider` pass locally.

Test commands

# Run the specific new test

fvm flutter test test/history/provider/history_providers_test.dart

# Run all tests

fvm flutter test test --no-pub --test-randomize-ordering-seed random

Assumptions

- The project uses Riverpod/NotifierProvider patterns (not legacy StateProvider) and `databaseProvider` can be
  overridden in tests.
- The `HistoryModel` has `name` and `printer` fields and `HistoryItem` expects `dbKey` as a `String`.
- The CSV/export utilities (csvUtilsProvider) are already present and functional.

Next steps / options

- If you'd like, I can:
    - Run the tests in the workspace and report the results.
    - Make the debounce duration configurable via a setting.
    - Implement Sembast-side filtering for improved performance on large data sets.
    - Add widget tests for `HistoryPage` and `HistoryToolbar`.



