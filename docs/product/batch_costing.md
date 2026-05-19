# Batch Costing

ClickUp Parent Task: `86c9pag08`

Final QA Task: `86c9uf7uv`

## Summary

Batch costing adds a dedicated workflow for quoting and saving multiple prints together without cluttering the existing single-print calculator screen.

The current calculator remains the fast single-print path. Batch costing is a separate guided flow for jobs that contain multiple files, multiple quantities, split printer/material assignments, or mixed manual and G-code sourced items.

## Product Intent

Users should be able to cost a client/job/order that contains multiple prints, including:

- The same model printed multiple times
- Multiple different models in one quote
- Prints split across different printers
- Prints using different materials, spools, colours, or resin
- Shared job-level adjustments such as additional cost, shipping, admin, packaging, or order-level fees
- G-code imported items that may need user-entered missing details before costing

The workflow should default to simple batch-wide choices, then let users opt into per-item or split-copy detail where needed.

## Goals

- Reduce repeated manual costing work across many jobs
- Reuse existing calculator rules for multi-job workflows
- Keep batch results understandable per item and as a total quote
- Support both G-code-driven and manual batch entry
- Preserve useful state while users move around the batch flow
- Allow completed batch quotes to be saved to history
- Keep the existing calculator screen focused on single-print costing
- Keep all batch UI hidden unless the batch costing feature flag is enabled

## Scope

### In Scope

- Dedicated batch costing flow separate from the calculator screen
- Manual batch item entry
- Single-file G-code batch import
- Multi-file G-code batch import
- Batch item review
- Quantity per batch item
- Batch-wide printer assignment
- Split-copy printer allocation across multiple printers
- Batch-wide material/spool assignment
- Split-copy material allocation across multiple materials/spools/colours
- Searchable printer/material selection where lists can grow
- Non-blocking stock warnings when required material exceeds selected stock
- Pricing values that can apply either to item scope or batch scope
- Item-level breakdown and batch total summary
- Saving named batch quotes to history
- Batch history display for saved quotes
- Feature gating through the existing version-code/admin/debug flow

### Out of Scope for V1

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

Batch costing must be hidden unless `batchCostingEnabled` is true.

Implementation: `batchCostingEnabledProvider` (in `lib/batch_costing/batch_costing_visibility.dart`) is a dual-gate requiring both `isPremium` AND a SharedPreferences boolean (`batchCostingEnabled` key, defaults `false`).

Expected behaviour:

- Default state: disabled
- Disabled: no batch costing UI is visible to normal users
- Enabled: developer/test users can access the batch flow
- Existing calculator and normal G-code import flows must continue to work when disabled
- Incomplete or batch-only screens must never be reachable by normal users

Hard gate rule:

- Every visible batch-costing entry, action, route, label, button, card, chip, banner, empty state, and affordance must be gated
- Each batch page includes a guard: `if (!ref.watch(batchCostingEnabledProvider)) return const SizedBox.shrink();`
- Entry point in `calculator_page.dart` is gated by `batchCostingEnabledProvider`
- Do not rely on route gating alone if the entry point remains visible
- Do not rely on hiding entry points alone if a route is still reachable through normal navigation
- Do not leave disabled batch UI visible when the flag is off
- Hidden developer/test toggles may exist, but normal users must see zero batch-related UI when disabled

## Entry Points

Batch costing has two product entry paths:

- Manual batch
- Import G-code batch

Manual and G-code are separate entry points because they start from different user inputs. Single-file and multi-file G-code import should still feel like one coherent G-code import journey.

## Expected V1 Flow

Manual path:

1. Manual batch setup creates the first manual item
2. Batch review shows real batch item state
3. User can add, edit, or remove manual items from review
4. Printer assignment
5. Material assignment
6. Pricing scope
7. Summary / quote
8. Save named quote to history or leave/start a new batch

G-code path:

1. User enters the batch G-code import flow
2. User selects one or more G-code files
3. Single-file import preserves the rich G-code review/detail experience where applicable
4. Multi-file import uses a compact list with optional per-file details/preview
5. Missing required details are captured before batch review
6. Batch review shows imported items
7. Printer assignment
8. Material assignment
9. Pricing scope
10. Summary / quote
11. Save named quote to history or leave/start a new batch

## Batch Items

A batch item represents one model/print line in a batch quote.

Minimum fields:

- Item id
- Display name or file name
- Quantity
- Print weight
- Print duration
- Source type: manual or G-code
- Optional import metadata

Quantity represents how many times that item/model is printed. Do not duplicate a single model into multiple rows just because quantity is greater than 1.

Examples:

- One Benchy printed 10 times = one item with quantity 10
- Three different files = three items with quantity 1 each
- A quantity 10 item may still be split across multiple printers/materials without duplicating the item row

## Manual Batch Entry

Manual batch entry captures the same core values normally pulled from G-code:

- Item name
- Quantity
- Print weight
- Print duration

Manual entry is for users who already know print weight/time or do not have G-code available.

The first manual item is created in the manual setup step. Batch review then lets the user add, edit, and remove items.

## Batch Review

Batch review is the shared checkpoint for manual and G-code items.

Expected behaviour:

- Show real batch items from shared batch state
- Auto-expand the first item when entering review if no item is already expanded
- Preserve user choice after manual expand/collapse
- Let users edit quantities/details
- Let users remove items
- Let users add more manual items
- Let users import more G-code files where available
- Continue only when required item details are valid

Source display:

- Item title should be the display name or file name
- Use a small source chip such as `Manual` or `G-code`
- Do not repeat the file name in a source subtitle

## G-code Import

The G-code batch flow should support selecting one or more files where platform support allows.

Rules:

- Parse each selected file independently
- Convert each successful parse into one batch item
- Use the file name as the default item name
- Default quantity to 1 per imported file
- Reuse the existing G-code parser
- Handle failures per file where possible
- Prevent duplicate files from being imported into the same batch session (duplicate path+name is silently skipped)
- Allow delete/remove of imported rows before continuing
- Allow importing more files without clearing the existing batch unless the user starts a new batch

Missing details:

- Missing weight or duration should not make an otherwise valid import fail
- Missing required values must be captured before continuing to batch review
- Rows should clearly show `Ready`, `Details needed`, or `Failed`
- Failed rows should only represent real parse/import failures

Preview/details:

- Multi-file import uses compact rows to avoid overwhelming the screen
- Each row can expose an info/details action
- The info/details action opens metadata and preview in a modal/sheet
- Metadata/preview UI should be shared with the existing rich G-code review/details UI where practical

Quantity rule:

- Quantity is not captured on the G-code upload/review screen
- Quantity is adjusted in batch review
- Multi-file import may show helper copy such as `Quantities can be adjusted in the next step.`

Existing single-print calculator G-code import must remain unchanged outside the batch flow.

## Printer Assignment

Printer assignment supports both simple and advanced cases.

Modes:

- Batch-wide: one printer applies to the full batch
- Per-item/split: individual batch items can allocate copies across printers

Expected behaviour:

- Batch-wide selection remains simple
- Per-item allocation must support quantity greater than 1 without duplicating line items
- A quantity 10 item can be split across multiple printers
- Split allocations must validate that allocated copies equal item quantity
- Allocation UI should avoid forcing users through error-first correction when auto-balancing is possible
- Quantity edits must update or reset stale assignment state

Selection UI:

- Prefer searchable, scrollable selection lists over large dropdowns for batch-wide assignment
- Split allocation should use the reusable split allocation picker
- The same split journey should apply to printers and materials

## Material Assignment

Material assignment mirrors printer assignment.

Modes:

- Batch-wide: one material/spool applies to the full batch
- Per-item/split: individual batch items can allocate copies across materials/spools/colours

Expected behaviour:

- Batch-wide selection remains simple
- Per-item allocation must support quantity greater than 1 without duplicating line items
- A quantity 10 item can be split across multiple materials/spools/colours
- Split allocations must validate that allocated copies equal item quantity
- Quantity edits must update or reset stale material assignment state

Selection UI:

- Prefer searchable, scrollable selection lists over large dropdowns for batch-wide assignment
- Split allocation should use the reusable split allocation picker
- The same split journey should apply to printers and materials

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
