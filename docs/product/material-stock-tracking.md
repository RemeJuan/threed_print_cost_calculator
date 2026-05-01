# Material stock tracking

## Context
- Users requested inventory visibility for remaining material.

## Decisions
- Display remaining stock.
- Deduct stock on save action.

## Tradeoffs
- No undo path.
- No device/cloud sync.
- Simpler implementation and lower maintenance.

## Rejected Ideas
- Full inventory management subsystem.
- Automatic cross-device sync.

## Implementation Notes
- Stock deduction is tied to history save action.

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

## TODOs
- Validate dedicated Materials page flow against current stock deduction behavior.
