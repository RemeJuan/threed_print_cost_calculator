# Batch Costing

ClickUp Task: `86c9u8fvv`

ClickUp Parent Task: `86c9pag08`

Final QA Task: `86c9uf7uv`

## Summary

Batch costing adds a dedicated workflow for quoting and saving multiple prints together without cluttering the existing single-print calculator screen.

The current calculator remains the fast single-print path. Batch costing is a separate guided flow for jobs that contain multiple files, multiple quantities, split printer/material assignments, or mixed manual and G-code sourced items.

Current implementation status:

- End-to-end gated flow is implemented: review -> printer assignment -> material assignment -> pricing scope -> summary/save
- Manual and G-code entry are both implemented
- Quantity edits happen in batch review, not during batch G-code import
- Saving completed batch quotes to history is implemented
- Existing single-print calculator and single-file G-code apply flow remain available outside batch mode

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
- Batch costing is available to all users: free tier allows manual entries (up to 3 items per batch), premium unlocks unlimited items and batch G-code import

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
- Access control through `PremiumAccessPolicy` (free: 3 items per batch, manual only; premium: unlimited items + G-code import)

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

## Access Model

Batch costing is available to all users with different limits:

- **Free tier**: unlimited batch quotes, up to 3 items per batch, manual entry only
- **Premium tier**: unlimited items per batch, batch G-code import (single and multi-file)

Free users who reach the 3-item limit see a quota feedback message instead of being blocked silently.

## Entry Points

Batch costing has two product entry paths:

- Manual batch
- Import G-code batch

Manual and G-code are separate entry points because they start from different user inputs. Single-file and multi-file G-code import should still feel like one coherent G-code import journey.

Implemented entry points:

- Calculator screen button -> `BatchCostingPage` (free quota limits apply)
- Existing `GCodeImportPage` keeps the normal single-file apply path for quantity 1 and switches into batch import mode only when multiple files are selected
- Batch review screen can add more manual items or open the batch G-code import page to add more files into the same in-memory batch session

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
3. Single-file import uses a focused add-to-batch review card inside the batch import page
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

Implemented quantity behaviour:

- Existing `GCodeImportPage` no longer exposes a quantity field
- Quantity 1 on the normal single-file G-code flow keeps the existing calculator apply path
- Batch G-code import defaults each imported file to quantity 1
- Batch quantities are adjusted later in batch review
- Multi-file import shows helper copy that quantities can be adjusted in the next step

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
- Per-item/split material mode: compare allocated usage against the selected material/spool stock

Users may have another partial roll, refill stock, or still want to continue the quote.

## Reusable Split Allocation Picker

Split allocation should use one reusable picker/model/helper for printers and materials.

Requirements:

- Open from `Split copies`
- Support search/filter
- Support adding allocation rows from filtered options
- Support editing allocated quantity per row
- Support removing allocation rows
- Validate inside the dialog/sheet before save
- Cancel must preserve previous allocation state
- Save must apply valid allocation to shared batch state

Validation rules:

- Total allocated copies must equal item quantity
- No allocation below 0
- No allocation above remaining quantity
- At least one allocation is required
- Prevent negative remaining quantities

Auto-balancing is preferred where practical. For example, if the default printer has 13 copies and the user assigns 10 to another printer, the default printer should automatically reduce to 3.

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

Pricing UI:

- Pricing values should prepopulate from existing settings/defaults where applicable
- Blank or zero values are allowed and mean the pricing value is not used
- Blank or zero values should be hidden from summary/history display
- Use compact per-field scope controls, not large full-width dropdowns where possible

Percentage display:

- Do not sum percentages across quantity
- A 4.5% item-scoped risk remains 4.5% per item, not 13.5% for three items
- Show the percentage rate plus calculated currency impact where possible

Examples:

- `4.5% per item -> R12.34 total`
- `4.5% batch -> R12.34 total`
- `R18.00 each -> R54.00 total`
- `R10.00 batch`

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
- Save/exit/start-new-batch actions

Display rules:

- Quantity affects item totals
- Batch-scoped values apply once
- Item-scoped values apply according to item quantity and item scope rules
- Existing single-print calculator totals must remain unchanged
- Monetary values must use the standard app currency formatter
- Do not hardcode currency symbols
- Percent values remain percentages
- Hide blank/zero pricing rows
- Hide zero-value adjustment rows that add no explanation
- Final total should be visually prominent

Actions:

- `Save quote` is the primary action before save
- `Return to calculator` is secondary
- `Back to pricing scope` is navigation/tertiary
- `Start new batch` should clear current batch state only after confirmation

## Save to History

Completed batch quotes can be saved to history.

Expected behaviour:

- Saving prompts the user to set a quote name
- Default name can be `Batch quote`, but the user must be able to change it before save
- Custom quote name is persisted
- Saved quote appears in normal app history
- History navigation must use the normal tabbed app shell, not a raw standalone history screen
- User must be able to navigate out normally after viewing history

Saved data should preserve enough detail to explain the quote later:

- Batch items
- Quantities
- Printer assignments
- Material assignments
- Pricing values
- Pricing scopes
- Calculated item totals
- Calculated batch total
- Created date/time
- Quote name

Existing single-print history must remain unchanged.

## Batch History Display

Batch history should be readable and avoid junk rows.

Rules:

- Show saved quote name
- Show real item/copy counts, such as `1 item · 12 copies` or `3 items · 26 copies`
- Use current global currency formatting for monetary display
- Hide blank/zero pricing rows
- Hide zero-value adjustment rows that add no explanation
- Percent fields remain percentages
- Existing single-print history remains unaffected

## State Persistence and Start New Batch

Batch state may persist while the user leaves and returns to the batch flow. This is useful and avoids frustrating data loss.

Because state persists, the flow must provide an explicit `Start new batch` action.

Expected behaviour:

- Leaving and returning preserves current batch state
- `Start new batch` clears current batch state only after confirmation
- Confirmation copy should make the clearing behaviour clear
- Starting a new batch should not affect saved history

## Analytics

Batch costing events are logged through `AppAnalytics` in `lib/core/analytics/app_analytics.dart`. The full event catalogue is documented in [`docs/analytics.md`](../analytics.md).

Events and their trigger points:

| Event | Trigger | Key params |
|---|---|---|
| `batch_started` | Manual add, single-file import, multi-file import | `source` |
| `batch_item_added` | Per-item after manual add or G-code import | `source` |
| `batch_item_removed` | Item delete from review or import list | `source` |
| `batch_item_edited` | Save on manual item edit dialog | `source`, `changed_quantity`, `changed_weight`, `changed_duration` |
| `batch_gcode_import_completed` | End of multi-file import loop | Counts: ready, needs details, failed |
| `batch_assignment_completed` | Continue from printer/material step | `type`, `mode`, `has_split_allocations` |
| `batch_pricing_completed` | Continue from pricing scope step | Field existence + scope params |
| `batch_summary_viewed` | Summary page mount | Item/quantity counts, split indicators |
| `batch_quote_saved` | After quote save | `outcome` |

Privacy constraints: No PII, no item names, no file names, no raw G-code content, no cost payloads. Only feature-interaction metadata.

## Architecture Notes

Implementation files:

- `lib/batch_costing/batch_costing_page.dart` — review screen (shared checkpoint)
- `lib/batch_costing/batch_gcode_import_page.dart` — single/multi-file G-code import
- `lib/batch_costing/batch_printer_assignment_page.dart` — printer assignment
- `lib/batch_costing/batch_material_assignment_page.dart` — material assignment
- `lib/batch_costing/batch_pricing_scope_page.dart` — pricing scope configuration
- `lib/batch_costing/batch_summary_page.dart` — summary/quote screen
- `lib/batch_costing/model/batch_costing_item.dart` — `BatchCostingItem` model
- `lib/batch_costing/state/batch_costing_state.dart` — `BatchCostingState`, `BatchAssignmentAllocation`
- `lib/batch_costing/state/batch_pricing_state.dart` — `BatchPricingState`
- `lib/batch_costing/providers/batch_costing_notifier.dart` — Riverpod `NotifierProvider` for state management
- `lib/batch_costing/helpers/batch_summary_calculator.dart` — pure calculation helper
- `lib/shared/providers/batch_costing_visibility.dart` — `batchCostingEnabledProvider` dual-gate
- `lib/history/components/batch_history_item.dart` — saved batch quote display in history
- Navigation uses `MaterialPageRoute` push/pop (no GoRouter integration)

General notes:

- Reuse existing calculator logic per item instead of introducing a second costing formula path
- Keep batch-specific state separate from the current single-print calculator state unless intentionally seeding values from it
- Use existing Riverpod/provider/notifier patterns for batch state
- Prefer pure helpers for calculation and scope handling
- Reuse existing route, validation, localization, and UI conventions
- Reuse existing G-code parser rather than duplicating parsing logic
- Reuse shared G-code metadata/preview UI instead of duplicating it
- Use one reusable split allocation picker for printer and material allocation
- Save/history should build on existing persistence/history patterns
- Do not introduce cloud/account/sync behaviour

## Localization

All new user-facing strings must be localized.

Rules:

- Add strings to `lib/l10n/intl_*.arb`
- Update every supported locale
- Run `fvm flutter gen-l10n` when required
- Generated localization output lives in `lib/l10n/app_localizations.dart`
- Use the existing generated localization pattern
- Widget tests that render localized text must include localization setup

## QA Checklist

Use this checklist against the actual app build. Run both disabled and enabled states.

### Access model

- [ ] Free users can start and save batch quotes (up to 3 items per batch)
- [ ] Premium users can add unlimited items and use batch G-code import
- [ ] Free users see quota feedback when adding items beyond the limit

### Entry and review

- [ ] Manual batch entry creates the first real batch item
- [ ] Manual batch item can be added, edited, and removed from batch review
- [ ] Batch review auto-expands the first item, then preserves manual expand/collapse choices
- [ ] Batch review preserves real item state while navigating forward/back inside the batch flow
- [ ] Start new batch asks for confirmation before clearing in-memory batch state

### G-code behaviour

- [ ] Existing single-file G-code import still applies values into the calculator
- [ ] Quantity 1 G-code import keeps the existing calculator flow
- [ ] Multi-file selection from `GCodeImportPage` switches into batch import mode on the same page
- [ ] Batch G-code import handles full success, partial success, and failure rows correctly
- [ ] Missing weight or duration can be filled in before continuing
- [ ] Duplicate files are skipped instead of creating duplicate batch items
- [ ] Batch import details/info sheet opens and shows metadata/preview
- [ ] Imported rows can be removed before continuing
- [ ] Quantity greater than 1 is handled from batch review, not the import screen

### Assignment steps

- [ ] Printer assignment supports both batch-wide and per-item modes
- [ ] Printer split allocations can cover the full item quantity without duplicating item rows
- [ ] Quantity edits reset stale printer/material assignment state when needed
- [ ] Material assignment supports both batch-wide and per-item modes
- [ ] Material split allocations can cover the full item quantity without duplicating item rows
- [ ] Stock warning appears when required material exceeds selected stock
- [ ] Stock warning does not block continue

### Pricing and summary

- [ ] Pricing scope defaults are correct: additional cost=batch, labour=item, risk=item, markup=item
- [ ] Batch-scoped values apply once to the batch total
- [ ] Item-scoped values apply according to item quantity rules
- [ ] Percentage rows show the rate without summing percentages across quantity
- [ ] Blank/zero pricing rows stay hidden where they add no explanation
- [ ] Summary shows item count, total quantity, total weight, total duration, item rows, and final total
- [ ] Existing calculator totals remain unchanged outside the batch flow

### Save and history

- [ ] Save quote prompts for a user-editable name
- [ ] Saved batch quote appears in normal tabbed history
- [ ] Batch history rows show real item and copy counts
- [ ] Existing single-print history still works unchanged

## Dead-Code Cleanup Expectations

After the feature has stabilized, check for and remove or consolidate:

- unused widgets
- unused providers/notifiers/helpers
- unused models/enums/extensions
- unused localization keys added for abandoned UI states
- abandoned placeholder screens/routes
- duplicate G-code preview/details code
- duplicate split allocation implementations
- stale imports
- debug prints/logging left from testing
- unreachable branches from old flow designs
- comments describing old behaviour that no longer exists
