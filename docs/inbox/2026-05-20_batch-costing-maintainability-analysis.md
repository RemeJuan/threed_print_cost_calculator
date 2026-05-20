# Batch Costing Maintainability Analysis

## Overview

Batch costing feature spans 28+ files across `lib/batch_costing/`. Primary concerns: large files, duplicated UI patterns, duplicated logic.

## File Size Summary

| File | Lines | Assessment |
|------|-------|------------|
| `batch_costing_page.dart` | 527 | Large — mixed concerns |
| `batch_costing_notifier.dart` | 443 | Acceptable but repetitive pricing setters |
| `batch_gcode_import_handler.dart` | 436 | Handler extracted from page |
| `batch_pricing_scope_page.dart` | 356 | Moderate — repetitive field cards |
| `batch_material_assignment_page.dart` | 311 | Moderate — uses shared shell |
| `batch_printer_assignment_page.dart` | 299 | Moderate — uses shared shell |
| `batch_allocation_picker_dialog.dart` | 284 | Acceptable |
| `batch_summary_calculator.dart` | 243 | Acceptable |
| `batch_quote_save_service.dart` | 159 | Extracted save logic |
| `batch_import_file_row.dart` | 133 | Acceptable |
| `batch_assignment_page_shell.dart` | 109 | Shared shell + generic header |
| `batch_costing_state.dart` | 104 | Acceptable (state) |
| `batch_single_import_view.dart` | 93 | Acceptable |
| `batch_missing_details_form.dart` | 90 | StatefulWidget owns controllers |
| `batch_gcode_import_details_sheet.dart` | 75 | Acceptable |
| `batch_gcode_import_body.dart` | 184 | Acceptable |
| `batch_searchable_selector.dart` | 74 | Acceptable |
| `batch_anchor_selector.dart` | 51 | Acceptable |
| `batch_import_state.dart` | 43 | Model (no Flutter deps) |
| `batch_costing_item.dart` | 188 | Acceptable (model) |
| `batch_split_copies_dialog.dart` | 35 | Thin wrapper |
| `batch_new_batch_dialog.dart` | 25 | Shared dialog |
| `format_utils.dart` (shared) | 31 | Shared duration formatting |
| `home_button.dart` (shared) | 10 | Shared home action |
| `batch_summary_page.dart` | 444 | Refactored (save extracted) |
| `batch_gcode_import_page.dart` | 107 | Thin shell delegating to handler |

## Findings

### 1. Duplicate Assignment Pages (P0)

`batch_printer_assignment_page.dart` and `batch_material_assignment_page.dart` are near-clones:
- Same Scaffold + SafeArea layout structure
- Same `when()` async loading/error states pattern
- Same `SegmentedButton<Enum>` with batchWide/perItem segments
- Same batchWide (searchable selector) vs perItem (ListView) conditional rendering
- Same `_nextEnabled()` validation logic
- Same `_continue()`: validate missing items -> BotToast -> analytics -> navigation
- Same bottom Row with Previous/Next buttons
- `_printerAllocationsFor` / `_materialAllocationsFor` — identical logic, different maps
- `_hasSplitPrinters` / `_hasSplitMaterials` — identical split detection logic

### 2. Gcode Import Logic Still in Page (P0)

Existing refactor plan `docs/inbox/2026-05-20_batch-gcode-import-refactor.md` extracted widgets (steps 1-5) but step 6 (import handler) was NOT completed. The page still contains: `_pickAndImport`, `_pickAndImportFromFiles`, `_applyDetails`, `_applySingleImportDetails`, `_confirmSingleImport`, `_removeRow`, `_removeSingleImport`, `_isDuplicate`, `_findItemById`, `_startWithFiles`.

### 3. Large File: batch_summary_page.dart (P1)

648 lines with too many responsibilities:
- Summary display UI
- Empty state UI
- Pricing formatting logic (`_pricingSummary`, `_lineTotalWithQuantity`)
- Quote save dialog + save logic + success dialog (lines 382-519)
- Start new batch dialog
- Split detection helpers
- Duration formatting

### 4. Duplicate Start New Batch Dialog (P1)

Identical `_showStartNewBatchDialog` in both `batch_costing_page.dart:438` and `batch_summary_page.dart:571`. Same AlertDialog, same `reset()` call.

### 5. Duplicate `_formatDuration` (P2)

Identical in `batch_costing_page.dart:417` and `batch_summary_page.dart:643`.

### 6. Duplicate Home Button (P2)

Every page has same `IconButton(Icons.home_outlined)` with `Navigator.popUntil((route) => route.isFirst)`:
- `batch_gcode_import_page.dart`
- `batch_printer_assignment_page.dart`
- `batch_material_assignment_page.dart`
- `batch_pricing_scope_page.dart`
- `batch_summary_page.dart`

### 7. Duplicate `_applyDetails` / `_applySingleImportDetails` (P2)

Both do same weight/duration parsing + override logic. One operates on `BatchImportRow`, other on `BatchSingleImport`.

### 8. `BatchImportRow` Mutable State Anti-pattern (P3)

`BatchImportRow` holds `TextEditingController`s as mutable fields. Page mutates via `setState()`. Controllers should be owned by widgets, not model.

## Task List

- [x] **P0: Extract shared assignment page base** — Composition helper: `buildAssignmentPageAppBar`, `buildAssignmentLoadingState`, `buildAssignmentErrorState`, `AssignmentModeHeader<T>`, `AssignmentNavRow` in `batch_assignment_page_shell.dart`
- [x] **P0: Complete gcode import handler extraction** — `BatchGCodeImportHandler` class in `batch_gcode_import_handler.dart` covers all import logic
- [x] **P1: Extract quote save logic from summary page** — `saveBatchQuote()` in `batch_quote_save_service.dart`
- [x] **P1: Extract shared `showStartNewBatchDialog`** — `showStartNewBatchDialog()` in `batch_new_batch_dialog.dart`
- [x] **P1: Move `_hasSplitPrinters`/`_hasSplitMaterials` to state** — Computed getters on `BatchCostingState`
- [x] **P2: Extract `_formatDuration` to shared utils** — `formatDuration()` in `format_utils.dart`
- [x] **P2: Extract home icon button pattern** — `homeButton()` in `home_button.dart`
- [x] **P2: Consolidate `_applyDetails` / `_applySingleImportDetails`** — Shared `_parseOverrideDetails()` static helper in handler
- [x] **P3: Migrate `TextEditingController` ownership from `BatchImportRow` to widgets** — Controllers removed from models; `MissingDetailsForm` owns controllers as StatefulWidget**

ClickUp Task: tbd
