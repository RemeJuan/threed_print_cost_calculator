# Performance notes (cross-cutting)

## Context
- Cross-feature performance issues were identified during recent releases.

## Decisions
- Introduce indexing where queries degrade.
- Batch reads to reduce query amplification.
- Move toward typed repositories.

## Tradeoffs
- Additional implementation complexity.
- Requires broad test updates and migration discipline.

## Rejected Ideas
- None explicitly recorded in backfill.

## Implementation Notes
- Noted issue classes: N+1 queries, full scans, excess state updates, redundant refreshes.

## Known Issues
- Performance regressions can still appear with large local datasets.

## TODOs
- Add performance tests.
- Add performance logging.
- Guard refresh logic to avoid redundant reloads.
