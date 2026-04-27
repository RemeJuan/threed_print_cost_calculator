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

## Known Issues
- Save-coupled deduction can be sensitive to duplicate save attempts.
- TODO: verify in code whether failed save/retry can lead to unintended repeated deductions.

## TODOs
- Add manual stock adjustments.
- Add low-stock alerts.
