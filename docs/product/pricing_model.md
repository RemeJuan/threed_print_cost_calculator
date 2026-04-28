# Pricing Model

## Summary

Adds a client-facing pricing layer on top of the existing cost calculator output. It should let users turn internal cost results into a consistent sell price without changing the underlying cost basis.

## Goals

- Let users apply markup without manual off-app calculation
- Support both default pricing behavior and per-job overrides
- Produce predictable final prices for quoting

## Scope

### In scope

- Markup percentage as a default pricing control
- Per-job markup override
- Fixed setup fee
- Final price rounding options: `.00`, `.99`, or none

### Out of scope

- Taxes, discounts, or coupons
- Customer-specific price books
- Marketplace, invoicing, or payment flows

## Key Decisions

- Markup % supports both a default value and a per-job override.
- Fixed setup fee is part of pricing output.
- Final price rounding supports `.00`, `.99`, or no rounding.

## Open Questions

- Should pricing defaults be global only, or optionally printer-specific later?

## Implementation Notes

- Build on top of existing calculator totals rather than replacing current cost calculation logic.
- Persist default pricing preferences locally, likely alongside other app settings in SharedPreferences or Sembast depending on final data shape.
- Expose pricing state through Riverpod so calculator result views and future quoting flows can share one source of truth.
- Keep user-facing labels in the existing l10n system.

## Dependencies

- Depends on existing calculator totals and result presentation.
