# G-code telemetry investigation — 2026-10-19

## Scope and evidence

Investigation combines GA4 Data API queries with current repository code and `docs/analytics.md`. GA4 property `336608299`, timezone `Etc/GMT-2` (inclusive date ranges):

| Window | Started | Selected | Failed | Parse success | Import success |
|---|---:|---:|---:|---:|---:|
| 2026-10-11..17 | 22 | 8 | 8 | 0 | 0 |
| 2026-10-04..10 | 30 | 22 | 19 | 3 | 4 |
| Alternative 2026-10-12..18 | 25 | 8 | 8 | 0 | 0 |

Latest selected extensions: 4 `3mf`, 2 `stl`, 2 `jpg`, no `gcode`. Prior: 4 `3mf`, 3 `gcode`, 3 `stl`, 2 `mp4`, plus other formats. Dashboard comparison supplied by user is 22/6 versus prior 31/19. This cannot be reconciled with above figures without exact dashboard date range, timezone, filters, event definition, and reporting configuration; do not treat as same cohort.

## Findings — current parser and flow behavior (before recommendations)

- `GCodeImportPage` emits `gcode_import_started` once per page instance, not per picker/import attempt (`_hasLoggedImportStarted`). It opens a distinct per-picker attempt ID, but that ID is not on the page-level started event. A multi-file selection diverts to batch and logs the diversion; the batch handler does not use the single-file controller.
- Single-file controller logs selected extension, validation/parse success, partial, or failure with attempt ID. Successful parsing is distinct from applying: `gcode_import_success` is emitted in page actions after calculator state update. `gcode_apply_to_calculator` occurs before mutation. Current documentation says these events exist, but funnel counts do not identify attempts across all these lifecycle stages.
- Batch handler parses files directly through `GCodeImportService`, bypassing controller validation and its per-file analytics. Multi-file mode emits one summary; single-file batch mode has no equivalent per-attempt parse telemetry. Batch summary's `total_count` is ready + needs-details + failed; duplicates are excluded and reported as `duplicate_skipped_count: 0`, although picker-side deduplication can skip them.
- Controller validation applies a 50 MiB size cap. For suspicious/unknown type or MIME, validator inspects only first 64 KiB; unrecognized content markers reject a file. Extension acceptance can bypass marker inspection when MIME looks textual. Parser recognizes several slicer metadata patterns, but current duration capture uses first matching value (`extractedDuration ??=`), and first raw layer-height value is retained. Cura `MATERIAL`/`MATERIAL2` and Prusa `cm3` formats are not represented in current patterns. These are targeted fixture hypotheses, not demonstrated causes of the production failures.
- Current batch path does not share controller validation/partial classification; partial metadata can instead become needs-details when weight/duration absent, while a result with no extracted metadata can still be accepted into batch. Errors are caught, but batch UI error text includes raw exception text; this is separate from the proposed telemetry privacy contract and merits review.
- `docs/analytics.md` lists `parse_status` and `failure_reason` event parameters and recommends GA Admin registration. Supplied GA4 custom dimensions are only `feature`, `file_type`, `source`, `wn_id`; therefore those event parameters cannot currently be grouped as dimensions in the described reporting. There is no per-attempt joined dimension; registration is nonretroactive. Do not register an attempt ID as a custom dimension.
- The documented and supplied implementation context places per-file failure classification in controller telemetry; it does not supply a production Sentry read/export. No production Sentry access/CLI is available here and DSN is write-only. Therefore no exception distribution or root exception cause can be asserted. Request sanitized, read-only export grouped by stage/category, app version, extension, size bucket, and slicer for matching date window; no raw filenames/content/PII.
- Paywall `paywall_viewed` counts (38 supplied) measure paywall views, not G-code import attempts. They cannot explain or substitute for import funnel denominators.

## Root-cause assessment and count interpretation

No established single root cause. The observed lower failure count (8 versus 19) coincides with fewer selections (8 versus 22) and a different selected-file mix, including unsupported-looking extensions and no `.gcode` in latest window. This is consistent with lower selected volume and/or more early validation rejection; it is not evidence parser quality improved. Zero recorded parse/import successes does not establish a global parser regression: funnel denominators are inconsistent (page-open started versus per-picker selected; batch paths under-instrumented; apply is a later milestone), and latest selected formats may never reach parser. Missing per-attempt join and unavailable Sentry evidence prevent stronger attribution.

## Prioritized recommendations (proposed future work; no parser changes made)

1. **Repair measurement before interpreting trends.** Use one attempt lifecycle across single and batch; align event denominators and register low-cardinality `parse_status`/`failure_reason` dimensions in GA Admin for prospective reporting. Document exact report timezone, dates, filters, and event names alongside recurring comparisons. Keep attempt IDs out of custom dimensions.
2. **Make terminal outcomes complete and exactly-once.** Give each picker invocation and each selected file a scoped attempt; record parse outcome and apply outcome separately. Deduplicate terminal logging per attempt, including superseded/cancelled work. A narrow controller fix now prevents stale validation failures and resolves metadata-read exceptions to failure state; it does not implement this full lifecycle.
3. **Use Sentry evidence responsibly.** Obtain the sanitized grouped export specified above before attributing production exceptions. If inaccessible, explicitly report unknown cause distribution.
4. **Validate parser hypotheses with fixtures and QA before parser edits.** Add reproducible coverage for 64 KiB marker false negatives, Cura `MATERIAL`/`MATERIAL2`, Prusa `cm3`, and invalid early duration/layer value followed by valid later value. Compare single/batch validation and partial semantics. Only then propose parser changes; this report makes none.

## Proposed per-attempt lifecycle

Model picker invocation as a parent attempt and each picked file as a child attempt (one child in single mode). Emit bounded fields only: `mode` (`single`, `batch`), `source` (existing allowlist), `file_type` (extension allowlist/`other`/`unknown`), `file_size_bucket`, `slicer` (known enum/`unknown`), `parse_status` (`success`, `partial`, `failed`, `not_run`), `failure_reason` (stable enum/`none`), terminal `outcome`, and `stage`. No filename, path, raw content, user label, raw exception, stack, or PII. Attempt ID may be used only as a short-lived join key where analytics policy permits, never as a custom dimension.

Lifecycle requirements:

1. **Attempt start:** emit once at picker invocation for both single and batch; selected file gets child start after selection. Page view/open remains separate and is not called attempt start.
2. **Picker cancellation:** record `picker_cancelled` when picker returns null/empty. Cancellation is terminal for invocation; no fake file parse outcome.
3. **Parse result:** selected child ends parse phase exactly once as success, partial, or failure. Unsupported/invalid files use stable failure reasons; parse failure is not an apply failure.
4. **Batch:** parent summary reports selected, duplicate-skipped, processed and terminal counts; per-file child outcomes remain available. Preserve distinction between ready/needs-details/failed where product semantics require, but define denominator and ensure counts reconcile.
5. **Stale/superseded cancellation:** if newer selection supersedes active work or owner is disposed, record one `superseded`/`cancelled` terminal for attempt; late async completion must not emit another terminal or mutate current state.
6. **Apply:** emit `apply_success` only after calculator/batch state mutation succeeds. Apply failure is distinct from parse result; never infer apply success from parse success or CTA tap.
7. **Terminal dedup:** enforce one terminal event per child and one per parent, idempotently at lifecycle owner. Picker cancel, parse terminal, superseded cancellation, and apply terminal must not double-count same stage.

## Implementation and test plan (future; no code changes in this lane)

**Likely files:** `lib/core/analytics/app_analytics.dart` (bounded event helpers/params); `lib/gcode_import/gcode_import_page.dart` (attempt start, picker cancel, diversion); `lib/gcode_import/gcode_import_controller.dart` (single-file parse terminal and stale attempt suppression); `lib/gcode_import/gcode_import_page_actions.dart` (apply success after mutation); `lib/batch_costing/providers/batch_gcode_import_handler.dart` (shared validation/outcomes, per-file and parent reconciliation, duplicate count, cancellation); `docs/analytics.md` (catalogue/schema and dimension guidance). Parser implementation files only after fixture evidence and separate approval.

**Tests:**

- Successful single: picker start -> selected -> parse success -> apply success; assert exactly one event at each relevant stage and parse/apply distinction.
- Successful batch: mixed ready and needs-details files; per-file parse outcomes, parent totals reconcile, and apply/continue outcome separate.
- Invalid/unsupported: size, extension/content, unsupported format; stable bounded reason and one failed parse terminal; no apply success.
- Recoverable/partial and unexpected: partial metadata produces partial, unexpected read/parse exceptions classify safely without raw details, one terminal.
- Cancellation: single and batch picker null/empty; cancellation terminal with no selected-file outcome. Include superseded async result and disposed owner; stale completion must not mutate/log terminal.
- Duplicates: duplicate-only and mixed duplicate/new batch; skipped count reconciles and no duplicate child parse attempt is falsely reported.
- Parser fixture tests (separate parser lane): each hypothesis above, including positive and negative markers and later-valid metadata after malformed early value.

Suggested existing test homes: `test/gcode_import/gcode_import_page_test_support.dart`, `gcode_import_controller_*_test.dart`, `gcode_import_page_actions_test.dart`, `gcode_import_parser_test.dart`, plus batch handler/page tests under `test/batch_costing/` (confirm exact existing filenames when implementation begins).

## Limitations

This is a code-and-GA4 aggregate assessment, not production exception forensics. Dashboard 22/6 versus prior 31/19 cannot be reconciled without its exact configuration. Parser hypotheses require representative sanitized fixtures/QA. Narrow controller fixes passed focused tests, `fvm flutter analyze`, and `make flutter_test` (947 tests); no parser behavior changes were made.
