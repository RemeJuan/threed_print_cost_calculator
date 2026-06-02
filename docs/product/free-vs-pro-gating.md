# Free vs Pro gating

## Context
- Free is now a useful default tier with quota limits (5 materials, 2 printers, 7 history saves, up to 3 items per batch quote).
- Premium unlocks unlimited capacity, business pricing, stock tracking, and advanced workflows.

## Decisions
- Free users get active limited access to materials, history, and batch costing (not teasers or demos).
- Locked UI indicators show upgrade value for premium-only features.
- Optional setting to hide upsell surfaces.

## Tradeoffs
- Softer monetization strategy.
- Improved trust and reduced aggressive friction.
- Free tier provides genuine utility, reducing immediate purchase pressure.

## Rejected Ideas
- Aggressive paywalls.
- Ad-supported monetization.
- Blocking UX for core calculator flow.

## Implementation Notes
- RevenueCat status is surfaced through provider state.
- Gating logic is centralized in `PremiumAccessPolicy` (`premiumAccessPolicyProvider`); the paywall presenter only opens the paywall screen.
- Custom app-owned `PaywallScreen` replaces the hosted RevenueCat paywall as the default user-facing upsell path.
- The paywall presenter pushes `PaywallScreen` through `appNavigatorKey` (defined in `app_providers.dart`).

## Premium Entry Points

| Entry point | Current behavior | Attribution |
|------------|------------------|-------------|
| Header icon | Free users see purchase CTA; premium users see G-code import | `source=header` |
| Premium feature tap | `requirePremium()` gates via `PremiumAccessPolicy`, opens paywall | `source=premium_feature` |
| History export | Upsell via `requirePremium()` for bulk/range export beyond free limits | `source=history_export` |
| Settings compact card | Free users see compact Premium card after Printers; hidden for premium users | `source=settings` |
| Help & Support premium FAQ | Free users see upgrade CTA inside existing Premium FAQ card; full comparison link remains | `source=faq` |
| Calculator premium footer | Informational only; `Learn more` opens in-app Premium FAQ, not paywall | No direct paywall source |
| What's New unlock CTA | Paywall after announcement CTA | `source=whats_new` |

## Known Issues
- Messaging clarity may still be inconsistent across entry points.

## TODOs
- Audit wording consistency across remaining upsell surfaces.
