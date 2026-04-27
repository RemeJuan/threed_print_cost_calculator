# History / search / pagination

## Context
- History usability degraded with datasets around 500+ entries.

## Decisions
- Added search capability.
- Planned pagination as follow-up scope.
- Kept a local-only storage/query model.

## Tradeoffs
- Limited indexing capability in current architecture.
- Potential performance degradation under larger datasets.
- Avoided backend complexity and sync requirements.

## Rejected Ideas
- Cloud sync.
- External search service.
- Full-text indexing engine.

## Implementation Notes
- Printer index lookup path implemented for search acceleration.
- Fallback path performs broader scans when index-assisted lookup is unavailable.

## Known Issues
- N+1 database reads in some fetch/render paths.
- Full-table scan fallback still occurs.
- Search input can lose focus during refresh cycles.

## TODOs
- Batch DB reads.
- Add indexes for name + printer fields.
- Fix input focus retention.
- Add caching around repeat queries.
- Add performance tests for large history sets.
