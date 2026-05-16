# Batch Costing

ClickUp Task: 86c9u8dqt

## Summary

Batch costing adds a dedicated workflow for quoting multiple prints together without cluttering the existing single-print calculator screen.

The current calculator remains the fast single-print path. Batch costing is a separate guided flow for jobs that contain multiple files, multiple quantities, or mixed printer/material assignments.

## Product Intent

Users should be able to cost a client/job/order that contains multiple prints, including:

- The same model printed multiple times
- Multiple different models in one quote
- Prints split across different printers
- Prints using different materials, spools, or resin
- Shared job-level adjustments such as additional cost, shipping, admin, packaging, or order-level fees

The workflow should default to simple batch-wide choices, then let users opt into per-item overrides where needed.

## Goals

- Reduce repeated manual costing work across many jobs
- Reuse existing calculator rules for multi-job workflows
- Keep batch results understandable per item and as a total quote
- Support both G-code-driven and manual batch entry
- Keep the existing calculator screen focused on single-print costing
- Make the feature safe to build over multiple releases behind a hidden debug/developer flag

## Scope

### In Scope

- Dedicated batch costing flow separate from the calculator screen
- Manual batch item entry
- Single-file G-code batch entry using quantity greater than 1
- Multi-file G-code batch import
- Batch item review
- Quantity per item
- Batch-wide printer assignment with optional per-item printer override
- Batch-wide material/spool assignment with optional per-item material override
- Non-blocking stock warnings when required material exceeds selected stock
- Pricing values that can apply either to item scope or batch scope
- Item-level breakdown and batch total summary
- Feature gating through the existing version-code/admin/debug flow

### Out of Scope for V1

- Saving batch quotes to history
- Exporting batch quotes
- Shareable quote images or PDFs
- Quote templates
- Customer/client records
- Tax settings
- Multi-currency changes
- Separate line items for shipping/admin/packaging
- Queue scheduling or production planning
- Multi-user collaboration
- Backend/cloud/account/sync work

## Feature Gate

Batch costing must be hidden behind a developer/debug flag while it is being built.

Expected behaviour:

- Default state: disabled
- Disabled: no batch costing UI is visible to normal users
- Enabled: developer/test users can access the batch entry point
- Existing calculator and G-code import flows must continue to work when disabled
- Incomplete batch screens must never be reachable by normal users
- Hard gate: every visible batch-costing entry, action, route, label, button, and card must check `batchCostingEnabled`
- Do not rely on route gating alone or on a hidden debug button alone
- Hidden developer/test toggles may exist, but normal users must still see zero batch-related UI when disabled

This is important because the work will likely span multiple branches and releases, while unrelated bug-fix releases may still need to ship.

## Entry Points

### G-code Review Quantity

The existing G-code review flow should support a quantity field.

Rules:

- Quantity defaults to 1
- Minimum quantity is 1
- Quantity 1 keeps the current behaviour and returns parsed values to the calculator
- Quantity greater than 1 starts the batch flow with one batch item
- CTA copy should change based on quantity:
  - Quantity 1: Use values
  - Quantity greater than 1: Create batch

This allows a single imported model to become a batch quote without requiring multi-file import.

### Batch Entry Screen

A dedicated Screen 0 should let the user choose how to start:

- Import G-code batch
- Manual batch

Both entry paths should merge into the same batch item review flow.

The batch review screen should let users add more manual items, edit existing items, and remove items before continuing.

## Expected V1 Flow

1. Entry method
2. Batch item review
3. Printer assignment
4. Material assignment
5. Pricing scope
6. Summary / quote

The user should not need to answer per-item questions unless they opt out of batch-wide defaults.

## Batch Items

A batch item represents one model/print line in a batch quote.

Minimum fields:

- Item id
- Display name or file name
- Quantity
- Print weight
- Print duration
- Optional source type: manual or G-code
- Optional import metadata

Quantity represents how many times that item/model is printed. Do not duplicate a single model into multiple rows just because quantity is greater than 1.

Examples:

- One Benchy printed 10 times = one item with quantity 10
- Three different files = three items with quantity 1 each
- Same model split across different printers/materials may require separate item assignments or future splitting support

## Manual Batch Entry

Manual batch entry captures the same core values normally pulled from G-code:

- Item name
- Quantity
- Print weight
- Print duration

Manual entry is for users who already know print weight/time or do not have G-code available.
The first manual item is created in the earlier setup step; the review screen extends that set.

## Multi-file G-code Import

The batch G-code path should support selecting multiple files where platform support allows.

Rules:

- Parse each selected file independently
- Convert each successful parse into one batch item
- Use the file name as the default item name
- Default quantity to 1 per imported file
- Reuse the existing G-code parser
- Handle failures per file where possible
- Allow the user to continue if at least one file parsed successfully

Existing single-file G-code import must remain unchanged outside the batch flow.

## Printer Assignment

Default behaviour should be batch-wide printer selection.

Flow:

- Ask whether one printer applies to the full batch
- Default to yes / batch-wide
- If the user switches to per-item mode, require a printer for each item
- Reuse existing printer selection patterns where practical

The user should not be forced to choose a printer per item unless they opt into that complexity.

## Material Assignment

Default behaviour should be batch-wide material/spool selection.

Flow:

- Ask whether one material/spool applies to the full batch
- Default to yes / batch-wide
- If the user switches to per-item mode, require a material for each item
- Reuse existing material selection patterns where practical

### Stock Warnings

Stock checks should warn, not block.

Examples:

- Batch-wide material mode: compare total required batch usage against selected material stock
- Per-item material mode: compare each item requirement against its selected material stock

Users may have another partial roll, refill stock, or still want to continue the quote.

## Pricing Scope

Pricing should not use one global scope selection. Each configurable pricing field should define where it applies.

Values keep their normal units. Scope only changes the calculation target.

Default scopes:

- Additional cost = batch
- Labour / processing = item
- Risk = item
- Markup = item

Supported scopes:

- Item: applies to the item/unit/item line according to the costing model
- Batch: applies once to the full job

Examples:

- 5% risk with item scope applies to the item calculation
- 5% risk with batch scope applies to the full job calculation
- $10 additional cost with batch scope applies once to the job
- $10 additional cost with item scope applies according to item quantity rules

Additional cost remains a single generic field in V1. Do not split it into shipping/admin/packaging line items yet.

## Summary / Quote

The summary should show enough detail for the user to understand both the item breakdown and total quote.

Expected summary content:

- Item count
- Total quantity
- Total weight
- Total print time
- Per-item cost breakdowns
- Batch-level adjustments
- Final total quote

Calculation rules:

- Quantity affects item totals
- Batch-scoped values apply once
- Item-scoped values apply according to quantity and item scope rules
- Existing single-print calculator totals must remain unchanged

## Architecture Notes

- Reuse existing calculator logic per item instead of introducing a second costing formula path
- Keep batch-specific state separate from the current single-print calculator state unless intentionally seeding values from it
- Use existing Riverpod/provider/notifier patterns for batch state
- Prefer pure helpers for calculation and scope handling
- Reuse existing route, validation, localization, and UI conventions
- Reuse existing G-code parser rather than duplicating parsing logic
- If persistence is added later, build on current Sembast/history patterns rather than a separate storage stack

## Suggested Task Breakdown

1. Feature gate and hidden entry point
2. G-code quantity enhancement
3. Screen 0 entry method shell
4. Batch item domain model and state
5. Manual batch item flow
6. Multi-file G-code import
7. Batch review screen
8. Printer assignment step
9. Material assignment step
10. Pricing scope step
11. Batch calculation and summary
12. Persistence/history deferral guardrail
13. Documentation and validation checklist

## Agent Execution Notes

Implementation agents should start from the assigned ClickUp subtask and read the shared execution contract before coding.

General expectations:

- Create one branch from latest main per subtask
- Open one PR per subtask
- Keep changes scoped to the assigned task
- Keep batch costing hidden unless the debug/developer flag is enabled
- Avoid unrelated refactors or formatting churn
- Run `fvm flutter analyze`
- Run relevant unit/widget tests
- Verify disabled feature flag behaviour for UI/navigation work

## Dependencies

- Existing calculator cost engine
- Existing G-code import and parsing flow
- Existing printer/material configuration
- Existing version-code/admin/debug flow
- Existing Riverpod state patterns
- Existing validation and localization patterns

## Open Questions

- How much per-item splitting is needed when the same model is printed across multiple printers/materials?
- Should batch quotes eventually save to history as one parent record or multiple linked item records?
- Should future quote sharing/export be CSV, PDF, image, or app-native first?
- Should discounts be added as a dedicated batch-scoped pricing field later?
