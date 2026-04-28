# Preset Import

## Summary

Adds local import of reusable preset data so users can bring settings into the app faster than manual re-entry. Initial scope is intentionally offline and file-based.

## Goals

- Reduce manual setup time for preset data
- Keep import flow simple and fully local
- Fit imported presets into existing app configuration patterns

## Scope

### In scope

- Local file import only
- Import of preset data into app-managed state

### Out of scope

- Marketplace or shared preset catalog
- Backend sync or account-based preset storage
- Remote fetching of preset files

## Key Decisions

- Preset import is local file import only.
- There is no marketplace or backend component in scope.

## Open Questions

- Which preset types are included in the first release?
- What import format should be accepted in v1?

## Implementation Notes

- Imported presets should map onto existing local models and settings flows instead of creating a parallel preset system.
- Riverpod should handle import state, validation feedback, and downstream UI refresh.
- Persistence should stay local, using current storage patterns such as Sembast or preferences where the target preset data already lives.
- File selection and parsing should remain intentionally simple for the first pass.

## Dependencies

- Depends on whatever existing preset/configuration models already exist in the app.
- No external service dependencies.
