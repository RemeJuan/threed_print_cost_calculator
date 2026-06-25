# Backup and restore

ClickUp Task: 86c9pafbe

Manual local backup and restore for Settings.

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
- Always restore free-visible data groups.
- When Premium is inactive at restore time, keep current local values for Premium-only pricing/config settings (`wearAndTear`, `failureRisk`, `labourRate`, markup/setup/rounding, currency display config) and restore everything else.
- Do not reject a backup just because it contains Premium-only fields.

## UI
- Settings section: export backup, restore backup.
- Restore requires confirmation warning.
- When Premium-only settings are skipped, show a non-blocking success note instead of failing restore.
- Export uses save dialog on desktop; share/download fallback otherwise.
- Mobile (iOS/Android): export uses native folder picker + direct file write, replacing same-named file on re-save. Share sheet fallback only on web.
