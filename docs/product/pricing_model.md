# Pricing Model

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

- **Base cost**: existing calculator total cost output. Current implementation target: same value app already treats as `CalculationResult.total` / `HistoryModel.totalCost`.
- **Markup %**: percentage applied to base cost only.
- **Setup fee**: fixed amount added after markup.
- **Rounding**: final presentation and storage adjustment applied last.

### Final Formula

```text
markupAmount = baseCost * (markupPercent / 100)
subtotal = baseCost + markupAmount + setupFee
finalPrice = applyRounding(subtotal, roundingMode)
```

### Order of Operations

Exact order:

1. Compute base cost using existing engine
2. Read effective pricing config for current job
3. Compute markup amount from base cost
4. Add markup amount to base cost
5. Add setup fee
6. Apply selected rounding rule to subtotal
7. Persist/display rounded result as final price

No alternate order allowed.

### Important Notes

- Markup applies to base cost only, not setup fee
- Setup fee is flat, never percentage-based
- Rounding happens once, at end
- Pricing layer must not mutate or feed back into base cost calculation

## Configuration

## Global Defaults

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
- Examples:
  - `12.00 -> 12.00`
  - `12.01 -> 13.00`
  - `12.31 -> 13.00`
  - `12.99 -> 13.00`

#### `.99`

- Exact rule:
  - If fractional part is `0`, keep value unchanged
  - Otherwise produce nearest price ending in `.99` that is **greater than or equal to** subtotal
- Operational definition:
  - If `subtotal % 1 == 0`, return `subtotal`
  - Compute candidate from current whole unit: `floor(subtotal) + 0.99`
  - If subtotal is less than or equal to candidate, use candidate
  - Else use `floor(subtotal) + 1 + 0.99`
- Examples:
  - `12.00 -> 12.00`
  - `12.31 -> 12.99`
  - `12.99 -> 12.99`
  - `13.00 -> 13.00`

### Zero Handling

To avoid nonsensical positive prices from rounding alone:

- If subtotal `<= 0`, final price is `0`
- Rounding rules do not transform `0` or negative values into `.99` or next integer

## Data Model

## Settings Storage

Add pricing defaults to settings layer alongside other global calculator defaults.

Recommended home:

- `GeneralSettingsModel`
- persisted through existing settings repository/service path

Recommended fields:

- `pricingMarkupPercent: String`
- `pricingSetupFee: String`
- `pricingRoundingMode: String` or enum-backed serialized value

Reason:

- pricing defaults behave like existing calculator defaults
- offline persistence already exists here
- no new storage mechanism needed

## Calculation / Job Storage

Current live calculator state needs pricing inputs and computed outputs separate from cost outputs.

Recommended additions to calculator state:

- `pricingMarkupPercent` input
- `pricingSetupFee` input
- `pricingRoundingMode`
- per-field override flags or nullable override values
- `pricingBaseCost`
- `pricingSubtotal`
- `pricingFinalPrice`

Recommended computed model:

```text
PricingResult {
  baseCost
  markupPercent
  markupAmount
  setupFee
  roundingMode
  subtotalBeforeRounding
  finalPrice
}
```

Keep this separate from `CalculationResult`.

Reason:

- cost model stays backward-compatible
- pricing output becomes reusable for future quote view
- UI can show both internal cost and client price without recomputing from ad hoc fields

## Saved Job / History Storage

Saved records must snapshot both effective pricing inputs and computed outputs at save time.

Recommended additions to saved job model/history model:

- effective `baseCost`
- effective `markupPercent`
- effective `markupAmount`
- effective `setupFee`
- effective `roundingMode`
- effective `finalPrice`
- optional indicator that job used overrides

Do **not** rely on re-reading current settings when opening old jobs or generating future shareable quotes.

## Calculator Integration

## UI Placement

Price should appear in calculator results, below or clearly separated from existing cost outputs.

Recommended display structure:

1. Existing cost breakdown stays as-is
2. Existing total cost stays as-is
3. New pricing section shows:
   - base cost
   - markup %
   - setup fee
   - rounding mode
   - final price

This preserves current mental model:

- cost = internal math
- price = what user charges client

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

## Acceptance Criteria

- Existing cost calculation output does not change
- Same cost + same pricing inputs always yields same final price
- Final formula and rounding behavior are documented and testable
- New jobs can use global defaults with no extra user setup
- Users can override markup/setup/rounding per job
- Saved jobs preserve computed price even after settings defaults later change
- Spec supports future shareable quotes without inventing second pricing path
