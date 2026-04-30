# Free vs Pro gating

## Context
- Conversion was weak and feature boundaries were unclear in earlier gating behavior.

## Decisions
- Added history teaser state for free users.
- Added locked UI indicators.
- Added optional setting to hide upsell surfaces.

## Tradeoffs
- Softer monetization strategy.
- Improved trust and reduced aggressive friction.

## Rejected Ideas
- Aggressive paywalls.
- Ad-supported monetization.
- Blocking UX for core calculator flow.

## Implementation Notes
- RevenueCat status is surfaced through provider state.
- Gating logic is centralized in the paywall presenter, but entry-point behavior still differs by surface.

## Premium Entry Points

| Entry point | Current behavior | Attribution |
|------------|------------------|-------------|
| Header icon | Premium users open G-code import; free users see the pro paywall/cart path | `source=header` |
| Calculator promo | Auto paywall after a run-count threshold | `source=premium_feature` |
| History teaser primary CTA | Direct paywall from teaser | `source=history_teaser_primary` |
| History teaser secondary CTA | Preview sheet, then paywall | `source=history_teaser_secondary` |
| History upsell/banner | Direct paywall from history surfaces | `source=premium_feature`, `purchaseSource=history` |
| What's New unlock CTA | Paywall after announcement CTA | `source=whats_new` |
| Settings locked sections | Analytics only; no paywall sheet launch | `source=settings` |

## Known Issues
- Messaging clarity may still be inconsistent across entry points.
- History teaser paths intentionally differ between primary CTA and preview/download CTA.

## TODOs
- Redesign paywall presentation.
- Improve messaging clarity and consistency.
- Decide whether settings lock tap should also open paywall or remain analytics-only.
