# G-code Import: Duplication Analysis & SafeArea Fix Plan

**Date:** 2026-05-20
**Status:** Ready for implementation

## Problem

1. Bottom buttons in batch flow obscured by Android nav bar
2. Duplicate SafeArea fixes needed across single & batch import flows

## Analysis: `gcode_import_page.dart` vs `batch_gcode_import_page.dart`

### Already Shared
- `GCodeImportMetadataSummary` widget (both pages)
- `GCodeImportService` / `GCodeImportFilePicker` same providers
- `GCodePickedFile` / `GCodeImportResult` models

### Duplicated Logic

| Area | Single Page | Batch Page | Action |
|---|---|---|---|
| **File picking** | `_pickFiles()` via `GCodeImportController` | `_pickAndImport()` inline, dedup check | Leave — different state models |
| **Import loop** | Delegated to controller provider | `_pickAndImportFromFiles()` inline | Leave — different state models |
| **Missing details form** | N/A (controller handles) | Duplicated within batch: `_buildSingleImportView` vs `_buildFileRow(needsDetails)` | **Extract** `_MissingDetailsForm` widget |

### Key Findings

1. **Internal duplication in batch page**: Weight/duration form fields ~40 lines appear in two places
2. **Cross-file duplication minimal**: Pages have fundamentally different state management & destinations
3. **Multi-file bridge**: Single page wraps `BatchGCodeImportPage(embedded: true)` when >1 file — this is the right pattern

### Already Fixed
- `batch_gcode_import_page.dart` — SafeArea around body + bottom buttons
- `gcode_import_page.dart` — SafeArea around body
- `batch_costing_page.dart` — SafeArea on bottom buttons
- `batch_material_assignment_page.dart` — SafeArea on bottom buttons
- `batch_printer_assignment_page.dart` — SafeArea on bottom buttons
- `batch_pricing_scope_page.dart` — SafeArea on bottom buttons

## Plan

1. Extract `_MissingDetailsForm` widget in `batch_gcode_import_page.dart` to remove ~40 lines duplication
2. Verify with `fvm flutter analyze` + `make flutter_test`
3. Update docs if architecture notes change
