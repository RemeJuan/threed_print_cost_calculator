# Multi-material

## Context
- Users requested multi-material costing while the original calculator engine only handled a single material.
- Backfill context indicates this was implemented as a v1 scope to avoid broad calculator refactors.

## Decisions
- Implemented weight-based split only across material rows.
- Kept a single shared duration for all materials.
- Did not implement per-material electricity modeling.

## Tradeoffs
- Reduced model accuracy for mixed-material prints with different machine profiles.
- Deterministic and predictable totals preserved.
- Avoided a major model and persistence refactor.

## Rejected Ideas
- Per-material time modeling.
- Full slicer integration.
- Mandatory G-code parsing as a prerequisite.

## Implementation Notes
- Material rows were introduced for calculator inputs.
- Total weight is normalized across rows.
- Backward compatibility with prior single-material records is preserved.

## Known Issues
- Multiple state emissions can occur during normalization.
- Possible UI performance impact when row edits trigger cascading updates.

## TODOs
- Collapse normalization to a single state update.
- Add stricter validation rules for row totals and edge cases.
- Hook this model into future G-code parsing flow.
