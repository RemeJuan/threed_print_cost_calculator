# Batch labour costing

## Goal

Calculate batch labour from hands-on work rather than printer runtime. Print duration remains relevant to machine-time and electricity calculations, but must never be used as labour time.

## Calculation

For hourly labour rate `R`, batch setup labour minutes `S`, and items `i` with per-unit labour minutes `Lᵢ` and quantity `Qᵢ`:

```text
labourCost = ((S + Σ(Lᵢ × Qᵢ)) / 60) × R
```

- Setup labour is counted once per batch.
- Item labour is per unit and multiplied by that item's quantity.
- Both time inputs default to zero; existing configurations without these values therefore retain zero labour cost until configured.
- Example: rate 120/hour, setup 15 minutes, item labour 10 minutes × quantity 3 = 90 labour cost.

## User experience

- Keep hourly-rate input labelled **Labour rate (per hour)**.
- Remove the Item/Batch rate toggle; this model has one hourly rate applied to batch setup and item labour.
- Add batch setup labour minutes, separate from the existing fixed Additional cost.
- Add per-unit hands-on labour minutes to each item, including item editing.
- Explain distinction between print duration (machine time) and hands-on labour time.
- Keep current visual style and existing batch costing flow.
- Do not add a new fixed-fee input. Existing batch-scoped Additional cost remains the fixed-fee mechanism and is independent of setup minutes.

## Cost integration

- Keep material, electricity, failure risk, markup, wear, printer allocation, and Additional cost behavior intact.
- Use revised labour in base costs so downstream risk, markup, and totals include it consistently.
- Item labour contributes to item base cost; batch setup labour contributes once to batch base cost.
- Do not derive labour from print duration or multiply setup labour by item quantity.
- Item-scoped risk and markup apply to item labour. Batch setup labour receives only batch-scoped percentages; no item-level setup allocation is implied.

## State, persistence, history, and export

- Store setup labour minutes on batch state and per-unit labour minutes on each batch item.
- Preserve values while navigating the batch flow and when reopening/editing an item.
- Include new labour inputs and breakdown in history snapshots and exports.
- Legacy saved records remain unchanged; absent new fields map to zero and must not trigger recalculation of historical totals.
- Add new CSV/XLSX fields without repurposing print duration or print-time columns.
- Existing exported **Setup Fee** represents Additional cost, not setup labour minutes; retain that meaning and use distinct labels/columns.

## Verification plan

Add or update focused tests for:

1. Zero defaults produce zero labour.
2. Batch setup labour is counted once regardless of item count.
3. Per-item labour scales by that item's quantity.
4. Different items can have different labour minutes; mixed-item batches sum correctly.
5. Additional cost remains independent of setup labour minutes.
6. Changing print duration does not change labour cost.
7. Revised labour flows through risk, markup, item/batch totals, and final totals.
8. Values survive navigation and item edit/reopen.
9. Legacy history maps missing labour fields to zero without changing stored totals.
10. History detail and CSV/XLSX exports preserve the new inputs and breakdown without changing print-time fields.

Update all supported locale ARBs for any new UI copy and regenerate localization with `fvm flutter gen-l10n`; do not edit generated localization files manually. Run model code generation if generated models change, then `fvm flutter analyze`, focused tests, and `make flutter_test`.
