# Admin tools (seeding + premium toggle)

## Context
- Internal QA/testing needed in-app tools for state setup and premium path validation.

## Decisions
- Version-tap unlock mechanism.
- Added seed, purge, and premium toggle actions.

## Tradeoffs
- Security through obscurity (not hard security).
- Low dependency and low implementation overhead.

## Rejected Ideas
- None explicitly recorded in backfill.
- TODO: verify in code if stronger auth-gated admin surfaces were considered.

## Implementation Notes
- Premium toggle uses a date-based code.
- Seed data lives in `assets/test_data/` as JSON, loaded by `SeedLoader` (`lib/shared/test_tools/seed_loader.dart`).
- `settings.json` keys: `generalSettings` (all calculator + pricing fields) and `sharedPreferences` (flags like `hideProPromotions`, `run_count`, `paywall`).
- `history.json` entries: standard fields (`name`, `totalCost`, `riskCost`, `filamentCost`, `electricityCost`, `labourCost`, `date`, `printer`, `material`, `weight`, `materialUsages`, `timeHours`) plus optional pricing fields (`pricingMarkupPercent`, `pricingMarkupAmount`, `pricingSetupFee`, `pricingRoundingMode`, `pricingSubtotalBeforeRounding`, `pricingRoundingAdjustment`, `finalPrice`, `pricingUsedOverrides`) and batch quote fields (`batchQuote`, `batchQuoteItems`, `batchQuoteSummary`).
- Batch quote history items set `batchQuote: true` and include `batchQuoteItems` (array of item breakdowns with `id`, `name`, `quantity`, `printerId`, `materialId`, `pricingProfileId`, `totalWeightG`, `totalPrintDurationMinutes`, `baseCost`, `additionalCost`, `finalTotal`, `pricing`) and `batchQuoteSummary` (aggregates: `itemCount`, `totalQuantity`, `totalWeightG`, `totalPrintDurationMinutes`, `finalTotal`, `printerAssignmentMode`, `materialAssignmentMode`, `batchPrinterId`, `batchMaterialId`, `pricing`).
- Pricing rounding modes: `"none"`, `".00"` (whole dollar), `".99"` (ends in .99).

## Known Issues
- App restart required after seeding for reliable UI/data refresh.

## TODOs
- Add runtime refresh after seed/purge actions.
- Reuse existing version string only for unlock display/logic.
