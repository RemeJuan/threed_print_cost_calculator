# Materials CSV upsert

## Summary

Add premium-only materials export/import for stock management.

Flow:
- User exports current materials CSV from app.
- User edits CSV outside app.
- User imports same CSV back into app.
- Import updates rows whose `id` matches an existing local material.
- Import creates rows whose `id` is blank or does not match an existing local material.

Imported CSV is the source of truth for material fields included in the schema, including stock-tracking state, remaining stock, and archived state.

## Goals

- Make stock management practical for users with many materials.
- Support spreadsheet-based bulk editing without a column-mapping UI.
- Reuse existing local materials storage.
- Keep import behavior predictable and summary-driven.

## Non-goals

- Cloud sync.
- Multi-device merge/conflict resolution.
- Name-based deduplication.
- Inline spreadsheet editing in app.
- Inventory purchasing workflows, reorder thresholds, or stock alerts.
- Arbitrary CSV schema support.

## Entitlement

- Export is premium-only.
- Import is premium-only.
- Gate both with the existing `stockTracking()` premium rule.

## User flow

### Start state

Materials screen header actions expose:
- **Export materials**
- **Import materials**

Import intro copy should make source-of-truth behavior explicit:

> Export your materials, edit the CSV, then import it back. Matching rows will update existing materials and new rows will be created.

### Review state

After file selection, show summary-first review:

- `13 rows found`
- `10 updating`
- `2 creating`
- `1 need fixing`

Use accordions/cards, not tables.

Recommended sections:
- **Needs fixing (N)** — expanded by default
- **Updating (N)** — collapsed by default
- **Creating (N)** — collapsed by default

CTA examples:
- `Apply 10 updates and create 2 materials`
- `Apply 8 updates and create 1 material`

Rows with issues are skipped if user continues.

### Result state

Show a persistent result summary before returning to Materials:

- `10 materials updated`
- `2 materials created`
- `1 row skipped`

Do not rely on a success toast alone.

## Canonical CSV schema

Only current exported schema is supported for import.

```csv
id,name,brand,material_type,color,color_hex,spool_weight_g,remaining_weight_g,spool_cost,track_remaining,archived,notes
```

### Column rules

- `id`
  - Optional.
  - Existing local match -> update.
  - Blank -> create.
  - Nonblank with no local match -> create as a new local record.
  - Imported `id` values are never persisted for created rows; app generates its own local ID.
- `name`
  - Required.
- `brand`
  - Optional.
- `material_type`
  - Optional.
- `color`
  - Required.
- `color_hex`
  - Optional.
- `spool_weight_g`
  - Required numeric.
  - Must be `> 0`.
- `remaining_weight_g`
  - Required numeric when `track_remaining=true`.
  - When `track_remaining=false`, still export/import a numeric value so the sheet remains complete and round-trippable.
  - Must be `>= 0`.
  - Must be `<= spool_weight_g`.
- `spool_cost`
  - Required numeric.
  - Must be `> 0`.
- `track_remaining`
  - Required boolean.
  - Accept only `true` / `false`.
- `archived`
  - Required boolean.
  - Accept only `true` / `false`.
- `notes`
  - Optional.

## Upsert rules

### Matching

- Match only on `id`.
- Never match on `name`, `brand`, `color`, or any other field.
- Duplicate names are allowed.

### Update

When a row `id` matches an existing local material, replace all schema-managed fields on that material with CSV values:

- `name`
- `brand`
- `materialType`
- `color`
- `colorHex`
- `weight`
- `cost`
- `autoDeductEnabled`
- `originalWeight`
- `remainingWeight`
- `archived`
- `notes`

Because the sheet is the source of truth, importing a row can:
- enable or disable stock tracking
- reset spool weight
- reset remaining stock
- archive or unarchive materials

### Create

Create a new material when:
- `id` is blank, or
- `id` does not match an existing local material

Created rows always receive a new local database ID.

### Quota behavior

- Free-tier material quota should count only created rows.
- Updated rows consume no material slots.
- Because import/export is premium-only, quota edge cases should mostly matter only if policy changes later, but service logic should still be correct.

## Archived behavior

Archived state must round-trip through storage and CSV.

Archived persistence now round-trips through storage:
- `MaterialModel.fromMap()` restores `archived`, defaulting missing values to `false`.
- `MaterialModel.toMap()` writes `archived`.

Expected persistence behavior:
- Existing records without `archived` field default to `false`.
- Export includes explicit `archived` column for every row.
- Import updates archive state from CSV.

## Validation

### File-level validation

Validate:
- File is readable text CSV.
- Header row exactly matches current exported schema.

Because import only supports current exported schema, reject other schemas instead of trying to map them.

### Row-level validation

Validate only import-breaking issues:
- Required fields present.
- Required numeric fields parse correctly.
- Required boolean fields parse correctly.
- `spool_weight_g > 0`.
- `spool_cost > 0`.
- `remaining_weight_g >= 0`.
- `remaining_weight_g <= spool_weight_g`.
- Row can be converted into a valid `MaterialModel`.

Do not validate:
- Duplicate names.
- Similar brands or colors.
- Unusual but valid numeric values.

## Parsing requirements

Parser must support normal CSV quoting rules:
- quoted commas
- escaped quotes
- CRLF/LF
- UTF-8 BOM
- optional blank lines
- quoted line breaks in fields such as notes

Current parser behavior is not sufficient because it splits on raw newlines before CSV parsing.

## Analytics

Keep existing import analytics pattern. Extend summary payloads as needed.

Recommended metrics:
- `rows_updating`
- `rows_creating`
- `rows_failed`

Do not log material IDs or names.

## Implementation plan

### Phase 1 — persistence correctness

- Persist `archived` in `MaterialModel.toMap()`.
- Restore `archived` in `MaterialModel.fromMap()` with default `false`.
- Add tests for archived round-trip.

### Phase 2 — CSV contract and export

- Define canonical export/import schema constants.
- Add materials CSV export service.
- Export all materials, including archived ones.
- Share file using existing temp-file/share flow.
- Add premium-gated export action in Materials header.

### Phase 3 — parser and row classification

- Replace current ad-hoc parser with standards-compliant CSV parsing.
- Parse rows into review model with classification:
  - updating
  - creating
  - invalid
- Use real file line numbers in review cards.

### Phase 4 — upsert service

- Add upsert service separate from current create-only CSV import service, or evolve existing service cleanly.
- Resolve existing IDs before commit.
- Apply creates and updates in one repository-level transaction.
- Re-check premium/quota rules at confirm time.

### Phase 5 — UI refresh

- Update import page copy for export-edit-import workflow.
- Add review sections for updating/creating/errors.
- Add persistent result summary screen/state.

### Phase 6 — docs, localization, analytics, tests

- Add/update localized copy.
- Update `docs/feature-map.md` and related docs when behavior lands.
- Add parser, service, and widget coverage.

## Testing plan

### Unit tests

- Archived round-trip persistence.
- Export row generation.
- CSV parsing with quotes, commas, BOM, CRLF, and multiline notes.
- Row classification into update/create/invalid.
- Create with blank ID.
- Create with unknown ID.
- Update with known ID.
- Full field replacement on update, including `archived` and stock fields.

### Widget tests

- Premium-gated export/import actions visible only when allowed.
- Import review counts for updating/creating/errors.
- CTA wording.
- Result summary wording.

### Verification

- `fvm flutter analyze`
- `make flutter_test`

## Open implementation choices

- Whether to keep one page with internal states or split import review/result into separate routes.
- Whether to keep current import analytics events and only extend params, or introduce new event names for upsert-specific review/result steps.
