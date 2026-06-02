# Improve electricity estimates with average print power

ClickUp Task: `86c9wg337`

## Product Rules
- `Wattage (Rated)` = listed/rated/max printer wattage
- `Wattage (Avg)` = optional estimated active-printing wattage
- `Electricity (Rated)` and `Electricity (Avg)` line items in results/history
- No `Act` label or concept
- Calculation precedence:
  1. Printer profiles exist → selected printer `Avg` if set, else printer `Rated`
  2. Zero printer profiles → global `Avg` if set, else global `Rated`
  3. Global values never override selected printer
- Batch: printer-only resolution, never global fallback

## Implementation Plan

### 1. Model & State changes
- `PrinterModel`: add optional `averageWattage` string field
- `PrinterState`: add `averageWattage` form field + validation
- `GeneralSettingsModel`: add optional `averageWattage` string field
- `PrinterState.isValidForSubmit`: avg optional but must be positive if set

### 2. UI form changes
- `add_printer.dart`: relabel existing watt → `Wattage (Rated)`, add `Wattage (Avg)` optional field
- `general_settings_form.dart`: same relabel + new field; resolve layout conflict with two-column row

### 3. Shared wattage resolver
- New helper under `lib/calculator/helpers/` or `lib/settings/`
- Returns `(effectiveWatts, mode: rated|average, scope: printer|global)`
- Replaces duplicated fallback logic in:
  - `calculator_settings_sync.dart`
  - `calculator_notifier.selectPrinter()`
  - `calculator_history_loader.dart`
  - batch path

### 4. Calculator result metadata
- Add `electricityMode` to `CalculationResult` (or equivalent snapshot)
- `calculator_results.dart`: show `Electricity (Rated)` or `Electricity (Avg)`

### 5. History snapshot preservation
- `HistoryModel`: add optional `electricityMode` field
- `save_form.dart`: preserve mode when saving
- `history_item_cost_rows.dart`: use saved mode for label
- Legacy entries with no mode → generic `Electricity` label

### 6. Batch costing
- Trace exact batch composition (risk: current `_itemBaseCost` only does labour)
- Wire printer-only resolver (never global fallback)
- Save electricity mode in batch quote history if surfaced

### 7. Startup migration
- Optional backfill for new fields; schema-compatible lazy migration sufficient

### 8. Localization
- New ARB keys: `wattageRatedLabel`, `wattageAvgLabel`, `resultElectricityRated`, `resultElectricityAvg`, etc.
- Run `fvm flutter gen-l10n`

### 9. Tests
- Precedence rules (printer vs global, avg vs rated, zero printers)
- UI form validation
- History save/load mode preservation
- Batch printer-only resolution
- Legacy entry display fallback

## Sequence
1. Model fields + form state + validation
2. Shared resolver + unit tests
3. Wire single-calculator flows
4. Result/history snapshot metadata
5. History display/load
6. Batch electricity path
7. L10n
8. Analyze + test

## Legacy Label Decision
- Legacy entries with no saved mode: keep generic `Electricity` label (not assumed `Rated`)

## Files Likely To Change
- `lib/settings/model/printer_model.dart`
- `lib/settings/state/printer_state.dart`
- `lib/settings/providers/printers_notifier.dart`
- `lib/settings/printers/add_printer.dart`
- `lib/settings/model/general_settings_model.dart`
- `lib/settings/general_settings_form.dart`
- `lib/calculator/provider/calculator_settings_sync.dart`
- `lib/calculator/provider/calculator_notifier.dart`
- `lib/calculator/provider/calculator_history_loader.dart`
- `lib/calculator/view/calculator_results.dart`
- `lib/calculator/view/save_form.dart`
- `lib/history/model/history_model.dart`
- `lib/history/components/history_item_cost_rows.dart`
- `lib/batch_costing/helpers/batch_summary_calculator.dart`
- `lib/batch_costing/helpers/batch_quote_save_service.dart`
- `lib/startup.dart`
- `lib/l10n/intl_*.arb`
