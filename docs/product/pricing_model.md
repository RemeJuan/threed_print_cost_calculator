# Pricing Model

ClickUp Task: 86c9paekd

## Summary

Add client-facing pricing on top of existing calculator cost output.
Cost math stays unchanged. Pricing reads current cost result, applies a small set of deterministic pricing rules, then produces a final sell price suitable for future shareable quotes.

## Goals

- Make pricing deterministic, simple, and explainable
- Keep cost and price separate
- Support global defaults with optional per-job pricing overrides
- Produce stable outputs that can later back shareable quotes
- Work fully offline

## Core Principles

- Cost is what the print costs you. Price is what you charge.
- Cost remains source of truth for internal calculation
- Price is additive layer, not replacement
- Same inputs always produce same price
- Pricing must be explainable in one sentence: `base cost + markup + setup fee, then rounding`
- Saved jobs and future quotes must snapshot pricing inputs and computed output so later settings changes do not rewrite past prices

## Currency Formatting

Pricing introduces basic currency display formatting for client-facing values.

Scope is formatting only. No exchange rates, conversions, or locale-aware formatting are included.

### Supported Configuration

* currencySymbol (string)
* currencyPosition (before | after)
* currencySpacing (boolean)

### Behavior

* Values remain numeric internally
* Formatting is applied only at display time

Examples:

* R95.30
* 95.30 €
* 95.30€

### Rules

* Symbol is optional (empty = no symbol shown)
* Position determines placement
* Spacing controls gap between symbol and value
* Must be consistent across:
    * calculator
    * history
    * export

### Non-Goals

* Currency codes (USD, EUR)
* Locale formatting (1,000 vs 1.000)
* Conversion or exchange rates

### Currency Application Scope

Currency formatting must be applied consistently to all monetary values displayed in the app.

**Applies to:**

* Electricity cost
* Filament cost
* Risk cost
* Labour/material cost
* Additional cost
* Cost total
* Markup amount
* Setup fee
* Rounding adjustment
* Final price
* Material price per unit (e.g. per kg)

**Does not apply to:**

* Percent values
* Time values
* Weight values
* Wattage or power
* Dimensions or volume
* Any internal or stored numeric values
* CSV exported numeric fields

**Rule:** Currency formatting is a display concern only and must not affect calculations, stored values, or exported raw data.

## Monetisation

- Pricing model is a Pro-only feature
- Global pricing defaults are editable only for Pro users
- Free users may see read-only pricing surfaces or upsell entry points where relevant

## In Scope

- Base cost from existing calculator engine
- Markup percentage
- Fixed setup fee
- Final rounding modes: none, `.00`, `.99`
- Global defaults in settings
- Job-level override support where UI exposes it
- Persisted computed price for saved jobs / future quote surfaces

## Out of Scope

- Taxes
- Regional pricing rules
- Tiered pricing
- Discounts, coupons, negotiated pricing workflows
- Hosted quote links, backend sync, server-side pricing

## Pricing Formula

### Cost vs Price

- **Cost**: what the print costs internally
- **Price**: what user charges client

Cost remains internal. Price is derived from cost and displayed separately.

### Definitions

- **Base cost**: existing calculator total cost output, including any additional cost (sundry) amount. Current implementation target: same value app already treats as `CalculationResult.total` / `HistoryModel.totalCost`; `additionalCostAmount` is summed into `CalculationResult.total` before pricing receives it.
- **Markup %**: percentage applied to base cost only.
- **Setup fee**: fixed amount added after markup.
- **Rounding**: final presentation and storage adjustment applied last.

## Additional Costs (Sundry)

### Summary

Single per-job additional cost with optional note. Included in base cost before pricing is applied.

### Behavior

- One numeric input for amount
- Optional free-text note
- Included in base cost before markup, setup fee, and rounding

### UI

- Located in Job Costs accordion
- Inline amount input
- Pencil/edit icon opens note modal

### Data Model

Stored per job/calculation.

- `additionalCostAmount: number`
- `additionalCostNote: string?`

### History

- Amount always visible
- Note visible via expand/accordion

### Constraints

- Single entry only
- No categories
- No presets

### Dependency

Feeds into pricing model calculation through base cost.

### Final Formula

```text
baseCost = calculatorOutputTotal + additionalCostAmount
markupAmount = baseCost * (markupPercent / 100)
subtotal = baseCost + markupAmount + setupFee
finalPrice = applyRounding(subtotal, roundingMode)
```

### Order of Operations

Exact order:

1. Compute base cost using existing engine
2. Include single additional cost amount in base cost when present
3. Read effective pricing config for current job
4. Compute markup amount from base cost
5. Add markup amount to base cost
6. Add setup fee
7. Apply selected rounding rule to subtotal
8. Persist/display rounded result as final price

No alternate order allowed.

### Important Notes

- Markup applies to base cost only, not setup fee
- Additional cost feeds base cost before markup
- Setup fee is flat, never percentage-based
- Rounding happens once, at end
- Pricing layer must not mutate or feed back into base cost calculation

## Configuration

### Global Defaults

Stored in app settings. Used automatically for every new calculator session and any job without local pricing overrides.

Default fields:

- `defaultMarkupPercent`
- `defaultSetupFee`
- `defaultRoundingMode`

### Per-Job Overrides

Per-job calculator state may override:

- wear & tear
- failure risk
- hourly rate
- processing cost inputs
- markup %

Per-job calculator state may **not** override through this pricing surface:

- base cost math
- setup fee
- rounding mode
- selected cost engine totals
- global defaults for other jobs
- saved historical computed prices after save

Recommended shape:

- Cost inputs keep existing job-level behavior
- Markup may store explicit job value when user changes it locally
- Setup fee and rounding resolve from settings defaults unless later product scope changes

This keeps behavior simple and avoids copying defaults into every draft job unless needed.

Setup fee is global-only in v1. Users configure it in settings, and individual jobs inherit it from the effective global pricing configuration. Per-job setup fee overrides are intentionally out of scope for the first implementation.

## Rounding Rules

Rounding logic must be currency-agnostic. It works on numeric values only and does not assume a currency symbol.
Rounding is opt-in. If enabled, rounding always rounds up and never rounds subtotal down.

### Modes

#### None

- Keep subtotal unchanged except normal numeric precision handling already used by app

#### `.00`

- Round up to next whole number, then format/store as whole-unit price
- If subtotal already ends in `.00`, keep that whole number
- Examples:
  - `12.00 -> 12.00`
  - `12.01 -> 13.00`
  - `12.31 -> 13.00`
  - `12.99 -> 13.00`

#### `.99`

- Produce next price ending in `.99` that is strictly above subtotal
- Exact integers do not stay exact in this mode
- Operational definition:
  - Compute candidate from current whole unit: `floor(subtotal) + 0.99`
  - If subtotal is less than candidate, use candidate
  - Else use `floor(subtotal) + 1 + 0.99`
- Examples:
  - `12.00 -> 12.99`
  - `12.31 -> 12.99`
  - `12.99 -> 13.99`
  - `13.00 -> 13.99`

### Behavior Summary

- `.00` means next whole number at or above subtotal
- `.99` means next `.99` above subtotal, never below subtotal and never equal when subtotal already ends in `.99`
- `.00 -> next whole number`
- `.99 -> next .99 above subtotal`

### Zero Handling

To avoid nonsensical positive prices from rounding alone:

- If subtotal `<= 0`, final price is `0`
- Rounding rules do not transform `0` or negative values into `.99` or next integer

## Data Model

### Settings Storage

Add pricing defaults to settings layer alongside other global calculator defaults.

Recommended home:

- `GeneralSettingsModel`
- persisted through existing settings repository/service path

Recommended fields:

- `pricingMarkupPercent: String`
- `pricingSetupFee: String`
- `pricingRoundingMode: String` or enum-backed serialized value where `none` means rounding is disabled
- `currencySymbol: String`
- `currencyPosition: String` (before | after)
- `currencySpacing: bool`

Reason:

- pricing defaults behave like existing calculator defaults
- offline persistence already exists here
- no new storage mechanism needed

Currency settings are stored alongside pricing defaults because they directly affect how final price is presented to users.

No separate rounding-enabled boolean is required. The rounding control can be represented by `pricingRoundingMode`, with `none` acting as the disabled state and `.00` / `.99` acting as enabled states.

### Calculation / Job Storage

Current live calculator state needs pricing inputs and computed outputs separate from cost outputs.

Recommended additions to calculator state:

- `additionalCostAmount`
- `additionalCostNote`
- `pricingMarkupPercent` input
- `pricingSetupFee` resolved value from global settings
- `pricingRoundingMode`
- job-level pricing override state for markup where exposed
- `pricingBaseCost`
- `pricingMarkupAmount`
- `pricingSubtotal`
- `pricingRoundingAdjustment`
- `pricingFinalPrice`

Recommended computed model:

```ts
PricingResult {
  baseCost
  markupPercent
  markupAmount
  setupFee
  roundingMode
  subtotalBeforeRounding
  roundingAdjustment
  finalPrice
}
```

Keep this separate from `CalculationResult`.

Reason:

- cost model stays backward-compatible
- pricing output becomes reusable for future quote view
- UI can show both internal cost and client price without recomputing from ad hoc fields

### Saved Job / History Storage

Saved records must snapshot both effective pricing inputs and computed outputs at save time.

Recommended additions to saved job model/history model:

- effective `additionalCostAmount`
- effective `additionalCostNote`
- effective `baseCost`
- effective `markupPercent`
- effective `markupAmount`
- effective `setupFee`
- effective `roundingMode`
- effective `roundingAdjustment`
- effective `subtotalBeforeRounding`
- effective `finalPrice`
- optional indicator that job used overrides

Do **not** rely on re-reading current settings when opening old jobs or generating future shareable quotes.

## Calculator Integration

### Settings

Group pricing defaults under **Pricing & Work Costs**.

This replaces or expands current **Work Costs** naming so pricing and cost-related defaults live in one place.

Fields:

- Markup %
- Setup fee
- Rounding mode (none | .00 | .99)
- Currency symbol
- Symbol position
- Spacing toggle

Notes:

- Rounding is optional
- If enabled, rounding always rounds up
- Pricing controls remain editable only for Pro users

Currency formatting applies only to display values. Internal calculations remain numeric and unaffected.

### Calculator

Move **Work time** next to **Printing Time**.

Rename existing calculator total label from **Total** to **Cost Total**.

Add a divider after cost outputs, then show a pricing section with:

- Markup
- Setup fee, if greater than `0`
- Rounding adjustment, if rounding enabled
- Final Price (Grand Total)

`Final Price` and `Grand Total` refer to same value. Treat them as equivalent and avoid showing duplicate rows for same number.

This preserves current mental model:

- cost = internal math
- price = what user charges client

When both values are present, Final Price should be visually primary and Cost Total should remain visible as supporting detail. Price must not replace or overwrite cost.

Final Price should be the value used by future client-facing surfaces such as quotes and share cards.

### Job-Level Overrides

Add a job-level settings section below **Printing Time**.

Section contains:

- Wear & tear
- Failure risk
- Hourly rate
- Markup

This section is job-level UI. It can adjust current job inputs without mutating global defaults or redefining cost vs price boundaries.

## Recalculation Triggers

Pricing recalculates whenever either side changes:

### Base cost changes

- print weight changes
- material usage changes
- spool/material cost changes
- electricity inputs change
- time changes
- labour inputs change
- wear-and-tear / failure-risk inputs change if they affect current base-cost output path
- imported G-code values applied
- history entry loaded

### Pricing config changes

- markup % changes
- setup fee changes
- rounding mode changes
- job-level markup override changes
- settings defaults change while job is using defaults

Implementation direction:

- existing cost submit path remains unchanged
- pricing layer subscribes to resulting cost output and effective pricing config
- one-way flow: cost -> pricing

## Interaction With Existing Cost Outputs

- Existing cost values remain visible and unchanged
- Existing `CalculationResult` remains cost-only
- Existing save/history behavior for cost must keep working
- Pricing adds new fields and UI, not replacement labels on old cost fields
- Cost stays visible even when price is present

## Edge Cases

### Zero or Negative Cost

- If base cost `<= 0`, final price = `0`
- Do not apply markup/setup/rounding into a positive client price when underlying cost is zero or negative
- UI may still show configured markup/setup inputs, but computed final price stays `0`

### Missing Inputs

- If existing calculator cannot produce a valid base cost yet, pricing output stays unavailable or `0` based on current cost behavior
- Pricing must not guess missing cost inputs
- If pricing config input missing, use default fallback:
  - missing markup -> `0%`
  - missing setup fee -> `0`
  - missing rounding mode -> `none`

### Very Small Values

- Very small positive subtotal still follows rounding rule
- Examples:
  - `0.04` with none -> `0.04`
  - `0.04` with `.00` -> `1.00`
  - `0.04` with `.99` -> `0.99`
- This is acceptable because user explicitly selected pricing rule

### Existing Risk Output

- Current calculator exposes risk separately from total cost
- Pricing spec intentionally uses whatever value app defines as base cost today, without changing engine semantics
- If cost engine later changes what counts toward total cost, pricing must consume that updated single base-cost output rather than duplicate cost logic in pricing layer

## History and Persistence

History must store:

- cost
- pricing inputs
- final price

History UI behavior:

- show final price when present as the primary client-facing value
- keep cost visible as supporting internal detail
- do not replace, overwrite, or recompute cost from price
- apply currency formatting consistently to all displayed price values

Export behavior:

- include pricing fields alongside cost fields
- include final price when present
- export raw numeric pricing values for reliable CSV parsing
- optionally include formatted display values later if a separate client-facing export is introduced

Saved records must remain snapshot-based so future settings changes do not rewrite old prices.

## Migration

New pricing fields default to:

- `markup = 0`
- `setup fee = 0`
- `rounding = none`

Existing history remains unchanged. No backfill required.

## Full Flow Example

Example inputs:

- Base cost: `120.00`
- Markup: `25%`
- Setup fee: `15.00`
- Rounding mode: `.99`

Calculation:

1. Base cost remains `120.00`
2. Markup amount = `120.00 * 25% = 30.00`
3. Subtotal before rounding = `120.00 + 30.00 + 15.00 = 165.00`
4. `.99` rounding chooses the next `.99` above subtotal = `165.99`
5. Final Price / Grand Total = `165.99`

Persisted snapshot:

- baseCost = `120.00`
- markupPercent = `25`
- markupAmount = `30.00`
- setupFee = `15.00`
- roundingMode = `.99`
- subtotalBeforeRounding = `165.00`
- roundingAdjustment = `0.99`
- finalPrice = `165.99`

Cost remains `120.00`. Price becomes `165.99`. Future settings changes must not alter this saved result.

### With Additional Cost

Example inputs:

- Calculator output total: `120.00`
- Additional cost (sundry): `15.00`
- Markup: `25%`
- Setup fee: `15.00`
- Rounding mode: `.99`

Calculation:

1. baseCost = `120.00 + 15.00 = 135.00`
2. Markup amount = `135.00 * 25% = 33.75`
3. Subtotal before rounding = `135.00 + 33.75 + 15.00 = 183.75`
4. `.99` rounding → next `.99` above subtotal = `183.99`
5. Final Price / Grand Total = `183.99`

Persisted snapshot:

- additionalCostAmount = `15.00`
- additionalCostNote = `null` (optional)
- baseCost = `135.00`
- markupPercent = `25`
- markupAmount = `33.75`
- setupFee = `15.00`
- roundingMode = `.99`
- subtotalBeforeRounding = `183.75`
- roundingAdjustment = `0.24`
- finalPrice = `183.99`

## Analytics

Track:

- pricing enabled in settings
- override usage per job
- markup value distribution
- rounding usage
- save with pricing vs without pricing

Recommended trigger points:

- when pricing settings change
- when job-level override state changes
- when a job is saved
- when future quote/client-view entry points use pricing output

## Offline Requirement

- All pricing config, calculations, quote prep state, and saved outputs must work without network access
- No backend dependency for defaults, overrides, or final price generation

## Non-Goals

- Taxes
- Regional pricing rules
- Tiered pricing

## Practical Implementation Notes

- Reuse existing settings persistence path for global defaults
- Add pricing state/provider next to calculator state rather than mixing sell-price fields into low-level cost helpers
- Keep price copy localized through existing l10n system
- Save effective pricing snapshot with history entries needed for future shareable quotes
- Prefer simple numeric storage and deterministic pure helper functions for rounding
- Ensure cost and price labels stay distinct in model names, persistence, analytics, and UI copy
- Keep currency formatting as a thin display layer separate from pricing calculation logic

## Acceptance Criteria

- Existing cost calculation output does not change
- Same cost + same pricing inputs always yields same final price
- Final formula and rounding behavior are documented and testable
- New jobs can use global defaults with no extra user setup
- Users can adjust job-level cost inputs and markup where UI exposes overrides
- Saved jobs preserve computed price even after settings defaults later change
- Spec supports future shareable quotes without inventing second pricing path
- Pro-only access and UI placement are unambiguous
- Rounding behavior is opt-in and always upward
