# Calculator accuracy fixes

## Context
- A regression existed where totals could remain incorrect when switching to a zero-cost material.

## Decisions
- Force recalculation on material change events.
- Synchronize selected material state with spool/material data dependencies.

## Tradeoffs
- Increased state update frequency.
- Tighter coupling between UI selection flows and calculator logic.

## Rejected Ideas
- Lazy recalculation.
- Partial or selective recalculation paths.

## Implementation Notes
- A central recalculation trigger was added for material selection changes.
- Dependency synchronization is enforced before displaying totals.

## Known Issues
- Increased recalculation paths may overlap with broader performance concerns.
- TODO: verify in code whether all zero-cost transitions are covered by a single unified trigger.

## Related: form state ownership (May 2026)

- Settings changes no longer silently mutate an in-progress calculator draft.
  Active form values survive navigation, tab switches, accordion collapse, and
  app-refresh events.
- Explicit Reset action (button near Save Print) discards draft and rehydrates
  from current settings/defaults.
- Zero and empty field values are preserved across remounts — no implicit
  defaults reload.
- Full details: [ADR 2026-05](../decisions/2026-05-calculator-form-state-ownership.md).

## TODOs
- Expand regression coverage for selection/switching edge cases.
- Audit other cost inputs for similar stale-total behavior.


## Risk Formula Fix (May 2026)

### Bug
- Risk was calculated against a subtotal that incorrectly included wear_and_tear.
- Final `total` displayed to user excluded the risk component.

### Canonical Formula
- `base_print_cost = filament_cost + electricity_cost + labour_cost`
- `risk_cost = base_print_cost * failure_risk_pct`
- `total_cost = base_print_cost + risk_cost + wear_and_tear_cost + additional_cost`

### Rules
- Risk is included in total_cost.
- Risk applies only to print-dependent costs (filament, electricity, labour).
- Risk must not apply to wear_and_tear_cost, additional_cost, setup fees, or any pricing/markup.
- additional_cost is included in total_cost but excluded from the risk base.
- Pricing/markup calculations must be applied after total_cost is computed.

### Fix Location
- `lib/calculator/provider/calculator_notifier.dart`

### Test Case
- Filament: $5.08, Electricity: $0.02, Labour: $18.00, Wear & Tear: $1.25, Risk: 10%
- Expected: base_print_cost=23.10, risk_cost=2.31, total_cost=26.66
