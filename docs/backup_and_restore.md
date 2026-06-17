# Backup and restore

ClickUp Task: 86c9pafbe

Manual local backup, restore, and scheduled automatic backup for Settings.

## Scope
- Export local DB data only: general settings, printers, materials, history.
- Exclude purchases, RevenueCat local state, analytics IDs, transient prefs/cooldowns.
- Backup format: JSON with `version`, `schemaVersion`, `createdAt`, optional `appVersion`, and `data`.

## Restore rules
- Parse and validate full file before any write.
- Reject unsupported schema/version.
- Restore replaces backed-up stores, not merge.
- Apply in one DB transaction.
- Rebuild history/printer indexes inside transaction.
- Refresh app state after success.

## UI
- Settings section: export backup, restore backup, schedule automatic backup.
- Restore requires confirmation warning.
- Export uses save dialog on desktop; share/download fallback otherwise.
- Mobile (iOS/Android): export uses native folder picker + direct file write, replacing same-named file on re-save. Share sheet fallback only on web.
- Scheduled backups are best-effort, premium-only, and overwrite one fixed JSON file.
