# Settings

## Context
Settings page is the central configuration surface. Recently migrated from accordion/collapse to always-expanded linear layout for simpler scroll behavior and reduced conditional UI.

## Section Order
Linear (no accordion), matches usage frequency high→low:

1. General
2. Pricing & Work Costs (premium only)
3. Printers (premium only)

## Recent Changes (May 2026)
- Removed all accordion expand/collapse in Settings
- Removed `AccordionMenu` + `AccordionItem` usage from Settings page
- Section order changed from General → Printers → Work Costs to General → Work Costs → Printers
- Printers always expanded when visible
- Printer list: content-sized `Column` (replaced fixed-height `SizedBox` + `ListView`)
- Extracted `PrinterListItem` as standalone widget
- Added `SettingsSection` card wrapper widget
- Printer `key` now uses stable `ValueKey(printer.id)` instead of index-only

## Premium Gating
| Section | Free | Premium |
|---------|------|---------|
| General | Visible | Visible |
| Pricing & Work Costs | Hidden | Visible |
| Printers | Hidden | Visible |

## Section Order Rationale
- General first: most frequently accessed (currency, units, default settings)
- Work Costs second: configured once, rarely changed
- Printers last: managed when printers change, least frequent


## Upcoming Changes
- Further tuning to section content and layout is expected

## Field Definitions

### General
- **Electricity cost (kWh)**: Cost per kilowatt-hour used to calculate electricity portion of print cost.
- **Watt (3D Printer)**: Default printer wattage used when a specific printer profile is not selected.

### Pricing & Work Costs
- **Materials / Wear + Tear**: Multiplier applied to base material cost to account for wear, maintenance, and overhead.
- **Failure risk (%)**: Percentage applied to base print cost (excluding wear adjustments) to model failed prints.
- **Hourly rate**: Labour cost per hour applied to print duration.
- **Markup %**: Optional percentage added on top of total calculated cost for pricing/profit.
- **Setup fee**: Flat fee added per job.
- **Rounding**: Optional rounding logic applied to final price (e.g. nearest 1, 5, 10).

### Printers
- **Printer profiles**: Stored configurations including build volume and wattage used in calculations.

## Defaults & Validation

- Numeric inputs default to `0` unless otherwise specified.
- Markup defaults to `0%`.
- Rounding defaults to `None`.
- Failure risk should be constrained between `0–100`.
- Negative values are not permitted.
- Empty inputs resolve to `0` at state level.

## State & Persistence

- All settings are stored locally (Sembast + preferences).
- Settings act as the source of truth for calculator defaults.
- Changes persist immediately on update (no explicit save required).
- State updates propagate through Riverpod providers.

## Calculation Dependencies

- General settings affect all calculations globally.
- Pricing & Work Costs directly impact total cost output.
- Failure risk is applied only to base print cost (not wear multiplier).
- Markup, setup fee, and rounding are applied after base cost calculation.

## Edge Cases

- Empty or cleared numeric fields resolve to `0`.
- Large printer lists should remain performant due to column-based rendering.
- Removing a printer should not break existing history records.
- Zero or missing pricing values should not block calculation, only reduce output.
