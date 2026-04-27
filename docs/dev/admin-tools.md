# Admin tools (seeding + premium toggle)

## Context
- Internal QA/testing needed in-app tools for state setup and premium path validation.

## Decisions
- Version-tap unlock mechanism.
- Added seed, purge, and premium toggle actions.

## Tradeoffs
- Security through obscurity (not hard security).
- Low dependency and low implementation overhead.

## Rejected Ideas
- None explicitly recorded in backfill.
- TODO: verify in code if stronger auth-gated admin surfaces were considered.

## Implementation Notes
- Premium toggle uses a date-based code.

## Known Issues
- App restart required after seeding for reliable UI/data refresh.

## TODOs
- Add runtime refresh after seed/purge actions.
- Reuse existing version string only for unlock display/logic.
