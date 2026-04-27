# Android backup gap

## Context
- iOS backup behavior was considered working while Android backup behavior remained unclear/incomplete.

## Decisions
- Support full backup on Android.

## Tradeoffs
- Platform inconsistency until Android parity is complete.

## Rejected Ideas
- None recorded in backfill.

## Implementation Notes
- TODO: verify in code exact Android backup wiring and current exclusions.

## Known Issues
- Android restore behavior is not fully verified.

## TODOs
- Implement Android backup completely.
- Verify restore behavior end-to-end.
