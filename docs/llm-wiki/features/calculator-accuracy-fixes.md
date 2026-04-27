# Calculator accuracy fixes

## Context
- A regression existed where totals could remain incorrect when switching to a zero-cost material.

## Decisions
- Force recalculation on material change events.
- Synchronize selected material state with spool/material data dependencies.

## Tradeoffs
- Increased state update frequency.
- Tighter coupling between UI selection flows and calculator logic.

## Rejected Ideas
- Lazy recalculation.
- Partial or selective recalculation paths.

## Implementation Notes
- A central recalculation trigger was added for material selection changes.
- Dependency synchronization is enforced before displaying totals.

## Known Issues
- Increased recalculation paths may overlap with broader performance concerns.
- TODO: verify in code whether all zero-cost transitions are covered by a single unified trigger.

## TODOs
- Expand regression coverage for selection/switching edge cases.
- Audit other cost inputs for similar stale-total behavior.
