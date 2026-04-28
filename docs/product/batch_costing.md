# Batch Costing

## Summary

Adds a way to process multiple jobs in one workflow instead of running the calculator one item at a time. Most likely first use case is applying existing costing rules to multiple imported G-code jobs.

## Goals

- Reduce repeated manual costing work across many jobs
- Reuse existing calculator rules for multi-job workflows
- Keep batch results understandable per job

## Scope

### In scope

- Multi-job processing
- Batch-oriented costing workflow
- Likely G-code import driven input path

### Out of scope

- Queue scheduling or production planning
- Multi-user collaboration
- Backend job orchestration

## Key Decisions

- Batch costing focuses on multi-job processing.
- Initial workflow is likely driven by G-code import.

## Open Questions

- Should the first release support manual multi-job entry, or G-code-driven batches only?
- What result summary level is needed in v1: per-job only, or per-job plus aggregate totals?

## Implementation Notes

- Reuse existing calculator logic per job instead of introducing a second costing formula path.
- Batch state and progress should be coordinated through Riverpod so import, review, and results can stay in sync.
- If jobs are saved, persistence should build on current Sembast history structures rather than a separate storage stack.
- Scope should stay aligned with current G-code import work to avoid building standalone ingestion paths too early.

## Dependencies

- Likely depends on G-code import and G-code auto-calc.
- Depends on existing calculator logic and, if persisted, history storage.
