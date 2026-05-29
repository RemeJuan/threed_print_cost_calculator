import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';

Future<bool> requirePremium(
  PaywallPresenter paywallPresenter,
  FeatureAccess access, {
  required String purchaseSource,
}) async {
  if (access.allowed) return true;

  AppAnalytics.safeLog(
    () => AppAnalytics.premiumFeatureTapped(
      access.feature.name,
      isPro: false,
      source: purchaseSource,
    ),
  );

  await paywallPresenter.present(
    'pro',
    triggerFeature: access.feature.name,
    purchaseSource: purchaseSource,
    source: purchaseSource,
  );

  return false;
}
