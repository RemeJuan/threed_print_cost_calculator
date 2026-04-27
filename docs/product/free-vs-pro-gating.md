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
- Gating logic is unified instead of fragmented by view.

## Known Issues
- Messaging clarity may still be inconsistent across entry points.
- TODO: verify in code whether all history entry points share identical gate copy/behavior.

## TODOs
- Redesign paywall presentation.
- Improve messaging clarity and consistency.
