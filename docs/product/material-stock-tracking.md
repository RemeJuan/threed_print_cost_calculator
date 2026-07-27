# Material stock tracking

## Context
- Users requested inventory visibility for remaining material.
- Later iteration expanded this into a first-class materials workflow instead of a settings-only form.

## Decisions
- Display remaining stock.
- Deduct stock on save action.
- Surface materials in a dedicated app tab between Calculator and History.
- Premium-gate the materials tab — available only to Pro subscribers.
- Store richer material metadata: `brand`, `materialType`, `colorHex`, and `notes`.
- Support premium-gated CSV import/export for bulk material upsert.
- Derive stock state from remaining/original weight percentage instead of absolute grams.

## Tradeoffs
- No undo path.
- No device/cloud sync.
- Simpler implementation and lower maintenance.
- Materials remain local-only and lightweight, not a full inventory or purchasing system.

## Rejected Ideas
- Full inventory management subsystem.
- Automatic cross-device sync.

## Implementation Notes
- Stock deduction is tied to history save action.
- Materials UI lives in `lib/materials/` and is reachable from the main tab bar.
- Search matches material name and brand.
- Filters are dynamic from saved material types plus stock chips.
- Both filter rows use implicit "all" behavior: no explicit "All" chip, and tapping an already-selected chip clears that filter.
- Stock states:
  - `outOfStock`: remaining weight `<= 0`
  - `lowStock`: remaining/original weight `<= 15%`
  - `inStock`: above low-stock threshold
  - `noTracking`: auto-deduct disabled or original weight missing/invalid
- Material cards show a color swatch from `colorHex` when present, else a named-color lookup, else deterministic fallback color.
- Material cards merge `materialType`, `brand`, and derived `cost/kg` into one metadata line, allow the name to wrap to two lines, and sort list results by stock state priority so out-of-stock items sink to the bottom.
- Canonical CSV columns: `id,name,brand,material_type,color,color_hex,spool_weight_g,remaining_weight_g,spool_cost,track_remaining,archived,notes`.
- Export includes all materials, archived and active.
- Import is strict current-schema only; header must match exactly.
- CSV upsert uses `id` matching for updates; blank/nonmatching `id` creates a fresh local record.
- Source-of-truth fields include stock tracking and archive state.

## Materials UX uplift

### Summary
- Promote materials from settings into dedicated first-class page.

### Changes
- Materials no longer buried in settings.
- Dedicated Materials screen/page.
- Improved visibility and management.

### Data enhancements
- Keep existing `cost per unit`.
- Keep existing `remaining stock`.
- Optional non-breaking additions: better name/label handling, notes field, optional supplier field.

### UX
- List materials with key info visible.
- Simplify edit/create flows.
- Keep current stock deduction behavior aligned with history save action.

### Scope
- UX improvement only.
- No inventory system.
- No stock history.
- No alerts or automation.

### Release note
- Patch-level UX improvement, not new feature.

## Known Issues
- Save-coupled deduction can be sensitive to duplicate save attempts.
- TODO: verify in code whether failed save/retry can lead to unintended repeated deductions.
- No dedicated manual adjustment flow yet outside editing remaining weight on the material record.
- CSV import currently depends on user-supplied files matching the expected schema exactly.
- CSV import/export behavior now aligns with the canonical upsert schema and round-trips archived/stock fields.

## TODOs
- Validate dedicated Materials page flow against current stock deduction behavior.
- Add manual stock adjustments.
- Add low-stock alerts.
- Add broader CSV parsing coverage and edge-case UX for malformed files.
- Keep CSV review/result UX summary-first and row-based rather than column-mapping based.
