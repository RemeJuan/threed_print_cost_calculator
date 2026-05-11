# Project Maintenance & Structure Review

Date: 2026-05-10
Model: DeepSeek

## Summary of Highest-Value Findings

1. **4x `formatWeight` duplication** — identical helper copy-pasted in 4 UI files. Move to `shared/utils/`.
2. **Form boilerplate triplication** — `material_form.dart`, `add_printer.dart`, `general_settings_form.dart`, `work_costs_form.dart` repeat same debounce+validator+sync pattern ~4 times.
3. **Business logic in UI** — `work_costs_form.dart` runs debounced `settingsService.update()` directly; `material_form.dart` calls repository after submit; `history_page.dart` orchestrates export domain logic.
4. **5 files >400 lines** — `gcode_import_parser` (540), `calculator_notifier` (511), `gcode_import_page` (501), `history_page` (443), `csv_import_page` (396). All have clean extraction seams.
5. **`gcode_import/` has 6 model/type files with 3+ classes each** — `result`, `controller`, `feedback_models`, `feedback_email` are dumpster files.
6. **Hidden test tools in production path** — `lib/shared/test_tools/` imported by `premium_state_notifier.dart` and `settings_version_tap_target.dart`. Intentional but risks dead-code pruning confusion.

---

## Findings Table

| File | Issue | Risk | Cleanup | Effort |
|------|-------|------|---------|--------|
| `lib/gcode_import/gcode_import_parser.dart` (540L) | Monolith: rules + parsing + streaming state + preview decode | Medium | Split into `parser/` with patterns, value-parsing, stream-state, preview modules | M |
| `lib/gcode_import/gcode_import_page.dart` (501L) | Page + result card + preview + feedback wiring in one file | Low | Extract `gcode_import_summary_card.dart`, `gcode_import_header.dart`, `gcode_import_actions.dart` | M |
| `lib/history/history_page.dart` (443L) | Shell + search debounce + export sheet + teaser + paywall | Medium | Extract export sheet, hint banner; move debounce into controller | M |
| `lib/history/components/history_item.dart` (336L) | Card + cost rows + summary + material breakdown + slidable | Low | Split header/cost-rows/summary/breakdown/slidable into sibling files | M |
| `lib/app/app_page.dart` (330L) | Shell + announcements + cancel feedback + tabs + nav | Medium | Extract `app_announcements.dart`, `app_cancel_feedback.dart`, `app_tabs.dart` | M |
| `lib/settings/materials/material_form.dart` (313L) | Validation in widget, persist in widget, 1 form = 1 file too big | High | Move `isFormValid` to notifier; extract `MaterialFormFields` widget; remove repo call from UI | S |
| `lib/gcode_import/feedback/gcode_import_feedback_page.dart` (314L) | Form fields + submit + attachment UI in single build | Low | Extract fields widget, attachment widget, submit button | S |
| `lib/shared/components/settings_version_tap_target.dart` (314L) | Complex hidden debug entry point with premium dialog + data seeding | Low | Move debug tools into dedicated `lib/shared/test_tools/` sub-route, split dialogs | M |
| `lib/gcode_import/gcode_import_result.dart` | 6 public types in one file | Low | Split `GCodeSlicer` + `GCodeParseWarning` + `GCodePreviewMetadata` into `model/` | S |
| `lib/gcode_import/gcode_import_controller.dart` | 4 types (controller + result + status + error + state) | Low | Move `GCodeImportStatus`, `GCodeImportError` to model file | S |
| `lib/gcode_import/gcode_import_file_picker.dart` | 3 types (picker + platform + picked file) | Low | Move `GCodePickedFile` to model | S |
| `lib/gcode_import/feedback/gcode_import_feedback_models.dart` | 6+ types | Low | Split per domain concept | S |
| `lib/gcode_import/feedback/gcode_import_feedback_email.dart` | 5 types (mailer + platform + metadata + draft) | Low | Split into service + model files | S |
| `lib/materials/widgets/material_filters.dart` | 3 types (filters + chip data + section) | Low | Move `_FilterChipData` + `_FilterSection` to own files or make private | S |
| `lib/history/components/history_item_actions.dart` | 3 types (controller + actions + action model) | Low | Move `_HistoryItemAction` to own file if reused | S |
| `lib/settings/work_costs_form.dart` (234L) | Debounced persistence + validation + number parsing in widget | **High** | Move debounce+persist to notifier/service; widget should only call `notifier.updateField()` | S |
| `lib/settings/general_settings_form.dart` (196L) | Same debounce+persist pattern | Medium | Centralize debounce helper; widget calls notifier | S |
| `lib/settings/materials/materials.dart` (142L) | `formatWeight` dup #1 | Low | Use shared helper | S |
| `lib/calculator/view/components/materials_selection/material_row.dart` (225L) | `formatWeight` dup #2 | Low | Use shared helper | S |
| `lib/calculator/view/material_select.dart` | `formatWeight` dup #3 | Low | Use shared helper | S |
| `lib/materials/widgets/material_card.dart` (265L) | `formatWeight` dup #4 + 3 types in file | Low | Use shared helper; split `_MergedInfoLine`, `_StockBadge` | S |
| `lib/materials/widgets/materials_page.dart` | `deleteMaterial`/`saveMaterial` in widget | Medium | Move persistence calls to notifier/provider | S |
| `lib/history/history_page.dart` | Export domain logic in widget | Medium | Move `_exportSelected`/`_showHistoryExportSheet` logic to a HistoryExportService | S |
| `lib/calculator/view/calculator_page.dart` | Premium gating + paywall trigger in widget | Low | Already mostly in providers; acceptable for shell page | — |
| `lib/calculator/view/subscriptions.dart` (241L) | Stream-based hooks + material-count computation in UI | Medium | Move stream wiring + count logic into a provider | S |
| `lib/settings/providers/materials_notifier.dart` (195L) | Validation duplicates `material_form.dart` | Medium | Consolidate into notifier; form reads `notifier.isFormValid` | S |
| `lib/settings/printers/add_printer.dart` (147L) | Validation duplicates `printers_notifier.dart` | Medium | Same pattern as materials — consolidate | S |
| `lib/materials/csv_import/csv_import_page.dart` (396L) | Import UI + preview table + validation + import logic in one file | Low | Extract `CsvImportPreviewTable`, `CsvImportValidationBanner` | M |
| `lib/core/analytics/app_analytics.dart` (562L) | Large but expected — event enum + mapping boilerplate | Low | Consider codegen if events grow further; OK for now | — |
| `lib/calculator/provider/calculator_notifier.dart` (511L) | State machine logic — large but cohesive | Low | Could extract calculation helpers into `calculator/helpers/` | M |
| Test gaps: `calculator_notifier`, `calculator_history_loader`, `settings_service`, `printers_notifier`, `cancel_feedback_service` | No unit tests for core providers/services | **High** | Write focused provider unit tests with mock DB | M |
| Test gaps: most `gcode_import/` source files (16 src, 6 test) | Under-tested parser, controller, feedback flow | Medium | Add parser edge-case tests, controller state machine tests | M |

---

## Safe Quick Wins

These can be done in a single PR with near-zero risk:

1. **Extract `formatWeight` to `shared/utils/weight_formatting.dart`** — 4 identical implementations, 4 files changed, delete local helpers. ~10 min.
2. **Split `GCodeImportResult` types into `model/` subfolder** — `gcode_slicer.dart`, `gcode_parse_warning.dart`, `gcode_preview_metadata.dart`. Pure moves, no logic changes.
3. **Split `GCodeImportFeedbackModels`** — same pattern. Move types to `feedback/model/`.
4. **Split `GCodeImportFeedbackEmail` types** — separate service impl from models.
5. **Remove duplicate validation from forms** — make `material_form.dart` and `add_printer.dart` read `notifier.isFormValid` instead of re-implementing validation. Already exists in notifiers. ~20 min.
6. **Centralize `Duration` debounce constants** — `200ms`, `250ms`, `300ms`, `400ms` appear across 8 files. Add `debounceDuration` constants in `shared/constants.dart`.

---

## Needs Careful Refactor

These need planning or benefit from paired PRs:

1. **`work_costs_form.dart` debounced persistence** — the `_onFieldChanged` → `settingsService.update()` pattern is domain logic. Should move to a notifier or a `WorkCostsFormController`. Touches settings service + widget.
2. **`history_page.dart` export flow** — `_showHistoryExportSheet` calls `CsvUtils`, analytics, premium check. Extract to `HistoryExportService` or `HistoryExportController`. Touches history + CSV + analytics.
3. **`app_page.dart` shell split** — announcements + cancel feedback are side-effect heavy. Split into dedicated widgets with clear `useEffect` isolation. Touches app shell startup — integration-test sensitive.
4. **`gcode_import_parser.dart` split** — the streaming state machine is the sticky part. Extract patterns + value parsing first (pure functions), then tackle `_StreamingParseState` as a separate extract.
5. **`calculator_notifier.dart`** — 511 lines of calculator state machine. Extraction candidates are `_calculateFilamentCost`, `_calculateElectricityCost`, etc. into `calculator/helpers/cost_calculator.dart`.

---

## Suggested PR Breakdown

| PR | Title | Files | Effort |
|----|-------|-------|--------|
| 1 | **Centralize `formatWeight` + debounce constants** | 8 files | S |
| 2 | **Split G-code import model blobs** | 4 files (result, feedback models, feedback email, controller types) | S |
| 3 | **Consolidate form validation into notifiers** | `material_form.dart`, `add_printer.dart`, `materials_notifier.dart`, `printers_notifier.dart` | S |
| 4 | **Extract work_costs debounce into notifier** | `work_costs_form.dart`, new notifier or method in existing | S |
| 5 | **Split `gcode_import_parser.dart`** | 1→5 files in `gcode_import/parser/` | M |
| 6 | **Split `gcode_import_page.dart` into widgets** | 1→4 files in `gcode_import/widgets/` | M |
| 7 | **Split `history_page.dart`** (export + hint) | 1→3 files | M |
| 8 | **Split `app_page.dart` shell** | 1→4 files | M |
| 9 | **Add provider tests** (calculator_notifier, printers_notifier, settings_service, cancel_feedback) | 4+ test files | M |
| 10 | **Split `history_item.dart`** | 1→5 files in `history/components/` | M |

---

## Recommended First PR

**PR #1: Centralize `formatWeight` + debounce constants**

- Zero behavior change
- 8 files touched, all deletions of local helpers + one new shared file
- Validates the "small, reviewable" constraint
- Takes <30 minutes, excellent warm-up for the rest of the cleanup
