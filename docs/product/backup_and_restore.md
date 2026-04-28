# Backup and Restore

## Summary

Adds local export and import for user data so people can preserve or move their app state. Initial scope centers on full JSON backup with room for selective restore where practical.

## Goals

- Let users export app data in a portable format
- Restore data safely across app installs or devices
- Preserve compatibility through schema versioning

## Scope

### In scope

- JSON-based full export
- JSON-based import
- Versioned backup schema
- Optional partial restore

### Out of scope

- Cloud sync
- Automatic scheduled backups
- Backend account-based restore

## Key Decisions

- Backup/export format is JSON.
- Restore/import uses a versioned schema.
- Partial restore is optional, not required for every import path.

## Open Questions

- Which data groups should be selectable for partial restore in the first pass?
- Should import merge with existing data or require explicit replace choices per data group?

## Implementation Notes

- Primary data sources likely include Sembast-backed records plus relevant local preferences.
- Migration/version handling should align with existing startup migration patterns so older exports can be upgraded safely.
- Riverpod can coordinate export/import progress and post-restore refresh of app state.
- File access should remain local-only through platform picker/save flows.

## Dependencies

- Depends on current local persistence layers, especially Sembast and stored preferences.
- Should align with existing migration/versioning behavior at app startup.
