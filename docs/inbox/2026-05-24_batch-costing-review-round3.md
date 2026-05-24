# Batch Costing Review Round 3 — Structural Debt Sweep

Date: 2026-05-24
Previous refs: `2026-05-20_batch-costing-maintainability-analysis.md`, `2026-05-14_maintenance-review.md`

## Scope

Third-pass structural review of `lib/batch_costing/`. Earlier reviews extracted shared shell components, quote save service, new-batch dialog, duration formatting, and home button. This round targets files that slipped through.

User-flagged starting points:
- `lib/batch_costing/batch_costing_page.dart`
- `lib/batch_costing/batch_printer_assignment_page.dart`
- `lib/batch_costing/batch_pricing_scope_page.dart`

## Current File Sizes

| File | Lines (before) | Lines (after) | Severity |
|------|-------|-------|----------|
| `batch_costing_page.dart` | 508 | 341 | HIGH → MEDIUM |
| `batch_costing_notifier.dart` | 443 | 342 | HIGH → MEDIUM |
| `batch_summary_page.dart` | 440 | 425 | HIGH → MEDIUM |
| `batch_pricing_scope_page.dart` | 349 | 339 | MEDIUM |
| `batch_printer_assignment_page.dart` | 324 | 191 | MEDIUM → LOW |
| `batch_material_assignment_page.dart` | 307 | 221 | MEDIUM → LOW |
| `batch_gcode_import_handler.dart` | 412 | 322 | HIGH → MEDIUM |
| NEW: `widgets/printer_allocation_card.dart` | - | 104 | - |
| NEW: `widgets/batch_costing_item_card.dart` | - | 213 | - |
| NEW: `helpers/batch_pricing_formatter.dart` | - | 55 | - |
| NEW: `helpers/batch_assignment_flow.dart` | - | 75 | - |
| NEW: `helpers/batch_gcode_import_helpers.dart` | - | 101 | - |

## Findings

### Bug: `ref.listen` inside `build()` — batch_costing_page.dart:62-64

```dart
ref.listen(batchCostingProvider, (prev, next) {
  _syncQuantityControllers(next.items);
});
```

`ref.listen` called unconditionally in `build()`. Every rebuild registers another listener. Controller sync fires N times per frame, not once. Risk: stale closures, leaked listeners, unpredictable side effects on dispose.

**Fix:** Move to `initState` via `ref.listenManual` or guard with a `_listenerAttached` flag.

### 1. Duplicate assignment helpers — printer vs material (MEDIUM)

Previous round extracted shell components (`AssignmentModeHeader`, `AssignmentNavRow`, `buildAssignmentPageAppBar`, loading/error states). However, the per-page helpers are still duplicated:

| Helper | Printer page | Material page |
|--------|-------------|---------------|
| `_allocationMapFor()` | `_printerAllocationsFor` (lines 164-179) | `_materialAllocationsFor` (lines 193-208) |
| `_nextEnabled()` | lines 181-186 | lines 210-219 |
| `_continue()` | lines 188-231 | lines 221-263 |

Each pair has identical business logic operating on different state maps (`itemPrinterAllocations` vs `itemMaterialAllocations`, `batchPrinterId` vs `batchMaterialId`). A shared AssignmentFlow mixin or base class would halve this.

### 2. Printer allocation card not extracted — printer page:234-324

`_PrinterAllocationCard` is a private widget in the page file. Equivalent UI for materials lives in `widgets/material_allocation_card.dart`. Inconsistent: material has `MaterialAllocationCard` widget, printer keeps it inline. Extract to `widgets/printer_allocation_card.dart`.

### 3. `batch_costing_page.dart` size + mixed concerns (HIGH)

508 lines. Single state class owns:
- Quantity controller lifecycle
- Debounced quantity-change toast
- Item list expansion state
- Add Manual dialog orchestration
- Edit item dialog orchestration
- Analytics events for add/remove/edit/start
- Missing-fields validation
- Continue/navigation
- Empty state widget
- Item card widget
- Detail row widget
- Source chip widget

The quantity-change debounce + toast at lines 316-336 is a UX concern leaking into page state. Controllers in a `Map<String, TextEditingController>` owned by the page state is a known anti-pattern (previous round flagged `BatchImportRow` for same issue).

### 4. `batch_costing_notifier.dart` printer/material duplication (HIGH)

Methods for printer assignment (lines 22-113) and material assignment (lines 115-217) are structurally identical:
- `setPrinterAssignmentMode` / `setMaterialAssignmentMode`
- `setBatchPrinterId` / `setBatchMaterialId`
- `setItemPrinterId` / `setItemMaterialId`
- `setItemPrinterAllocations` / `setItemMaterialAllocations`
- `addItemPrinterAllocation` / `addItemMaterialAllocation`
- `removeItemPrinterAllocation` / `removeItemMaterialAllocation`

Each pair differs only by which state fields they mutate. Generic allocation methods would fold 12 methods into 4.

### 5. `batch_gcode_import_handler.dart` mixes UI and business logic (HIGH)

Despite "Handler" naming suggesting use-case layer, this class (412 lines) does:
- File import orchestration
- Provider mutation
- `ScaffoldMessenger` snackbar display
- `Navigator.push` calls
- Widget-local `setState` invocations
- Mounted tracking
- Parse fallback logic

Hard to unit test without widget harness. Import logic (`_pickAndImportFromFiles`, `_parseOverrideDetails`) should be separated from UI orchestration (snackbar, navigation, setState).

### 6. `batch_pricing_scope_page.dart` — controller/lifecycle duplication (MEDIUM)

Four identical field patterns (lines 131-202):
- Each defines controller, focus node, scope segmented button, validator
- `_loadDefaults` checks each field individually (lines 87-101)
- `dispose` releases each controller/focus individually (lines 64-74)
- `_continue` builds analytics payload with per-field scopes (lines 322-342)

Calls for a `PricingFieldConfig` data class + factory widget that owns one controller/focus/validator setup.

### 7. `batch_summary_page.dart` — size + mixed concerns (MEDIUM)

440 lines. Combines:
- Summary display
- Pricing formatting (`_pricingSummary`, `_lineTotalWithQuantity`)
- Settings read for currency format
- Analytics dispatch
- Save/start-new batch actions

`_pricingSummary` (lines 361-409) is pure formatting logic — belongs in a formatter or view model, not a state class.

## Untested Logic

No dedicated test files for:
- `lib/batch_costing/providers/batch_costing_notifier.dart`
- `lib/batch_costing/providers/batch_gcode_import_handler.dart`

These are the two largest business-logic providers. Everything currently tested through widget tests that override the notifier.

## Task List — Progress

- [x] **BUG: Move `ref.listen` out of `build()`** — Moved to `initState`. Cleanup: removed `_quantityChangeTimer` from page.
- [x] **HIGH: Extract printer/material assignment helpers** → `helpers/batch_assignment_flow.dart` (3 shared functions: `batchAllocationsFor`, `batchNextEnabled`, `batchContinueFlow`). Both pages shrunk ~85 lines combined.
- [x] **HIGH: Split `batch_costing_notifier.dart`** — Removed 6 dead methods (`setItemPrinterId`, `setItemMaterialId`, addItem/removeItem printer and material allocation methods) + `_replaceSingleAllocation`. Collapsed 12 allocation methods to 6 via shared `_updateAllocations`/`_normalizeAllocations`. File 443→342 lines.
- [x] **HIGH: Separate import orchestration from UI in handler** → `helpers/batch_gcode_import_helpers.dart` (5 pure functions). Handler delegates import logic to helpers. Pure logic now independently testable.
- [x] **MEDIUM: Extract `_PrinterAllocationCard`** → `widgets/printer_allocation_card.dart` (public `PrinterAllocationCard`, 107 lines).
- [x] **MEDIUM: Extract pricing field config** — Folded 4 build call sites into loop with `_PricingField` data class. Simplified `dispose` with arrays, added `scopeLabel` helper in `_continue`.
- [x] **MEDIUM: Move `_pricingSummary` to formatter** → `helpers/batch_pricing_formatter.dart` (top-level `formatPricingSummary`, 55 lines).
- [x] **MEDIUM: Reduce `batch_costing_page.dart`** — Extracted `BatchCostingItemCard` (224 lines) to `widgets/batch_costing_item_card.dart`. Page shrank from 508→342 lines.
- [x] **FIX: `ref.listen` → `ref.listenManual` in `initState`** — `ref.listen` asserts `debugDoingBuild`, fails in test lifecycle. Changed to `ref.listenManual` for lifecycle-safe listener registration.
- [x] **LOW: Add direct unit tests** — `batch_costing_notifier_test.dart` expanded from 2→14 tests (item CRUD, printer/material assignment, pricing). New `batch_gcode_import_helpers_test.dart` with 16 tests (6 parsing, 3 find, 4 duplicate, 2 build result, 1 build item). Total 30 new tests, all passing.
- [x] **FIX: 3 broken test call sites** — `setItemPrinterId`/`setItemMaterialId` removed in notifier sweep; tests updated to use `setItem*Allocations`.
