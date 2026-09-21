# RevenueCat Customer Center

## Status

Implemented in the app. RevenueCat Pro plan confirmed. Dashboard setup remains required before release.

## User behavior

- Settings exposes **Manage purchases** to every mobile user, whether free or premium.
- It opens RevenueCat's native Customer Center. Existing custom paywall and restore entry remain unchanged.
- Customer Center provides subscription management, restore support, and configured support contact. Refund requests and plan changes are iOS-only where RevenueCat and the store permit them.
- Selecting cancellation or a refund request never locally revokes premium access. RevenueCat entitlement state remains authoritative until the store reports expiry or revocation.
- No cancellation surveys, retention promotions, custom actions, or custom URLs in the first release.

## Implementation contract

- `CustomerCenterPresenter` is an injectable purchases-layer abstraction with `Future<void> present()`.
- The RevenueCat implementation calls `RevenueCatUI.presentCustomerCenter()` after the SDK has been configured. It must serialize duplicate presentations and surface errors to the caller.
- The Settings component owns user-facing localized busy/error feedback. The presenter owns no `BuildContext`.
- Customer Center restore/purchase changes flow through the existing RevenueCat customer-info listener and `PremiumStateNotifier`. On dismissal or store return, refresh safely if required; transient refresh failure must preserve the last confirmed premium state.
- Unsupported platforms do not attempt native presentation. The Settings entry is mobile-only.
- Store-formatted prices and currency symbols are allowed inside RevenueCat's native billing UI only. Calculator values and app-owned UI remain currency-agnostic.

## RevenueCat dashboard setup

Before release, configure Customer Center under Project Settings → Monetization Tools:

1. Enable its default management paths: cancellation and missing purchase; retain iOS-only refund and plan-change paths only if desired.
2. Configure a support email and Contact Support visibility.
3. Review Customer Center localization and light/dark appearance. RevenueCat owns these native strings; app ARBs do not.
4. Leave promotional offers unconfigured for this release. If later enabled, create and map matching offers in both App Store Connect and Google Play Console first.

## Verification

- Unit/widget: presenter serialization and errors; free/premium Settings visibility; localized feedback; entitlement updates after restoration; cancellation does not cause local downgrade.
- Automated: localization generation, `fvm flutter analyze`, `make flutter_test`, and relevant Settings/purchases integration coverage.
- Release evidence: iOS sandbox and Android test-track checks for launch, restore, manage/cancel handoff, return to app, support, dark mode, and platform-specific actions. Native store behavior cannot be established by fake gateway tests.

## Sources

- https://www.revenuecat.com/docs/tools/customer-center
- https://www.revenuecat.com/docs/tools/customer-center/customer-center-flutter
- https://www.revenuecat.com/docs/tools/customer-center/customer-center-configuration
