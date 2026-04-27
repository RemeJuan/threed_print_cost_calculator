# Form validation

## Context
- Invalid data was entering persistence and calculation flows.

## Decisions
- Enforce required fields on forms.

## Tradeoffs
- Slight increase in UX friction.
- Better data quality and reduced downstream errors.

## Rejected Ideas
- None recorded in backfill.
- TODO: verify in code if soft-validation-only approaches were attempted and dropped.

## Implementation Notes
- Validation is primarily implemented at form level.

## Known Issues
- Duplicate numeric parsing logic exists in multiple paths.

## TODOs
- Create shared parsing utility.
- Improve validation feedback quality and specificity.
