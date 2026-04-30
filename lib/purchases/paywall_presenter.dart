import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

abstract class PaywallPresenter {
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  });
}

final paywallPresenterProvider = Provider<PaywallPresenter>((ref) {
  return const _RevenueCatPaywallPresenter();
});

class PaywallPresentationGate {
  static bool _isShowing = false;

  static Future<T?> show<T>(Future<T> Function() action) async {
    if (_isShowing) return null;

    _isShowing = true;
    try {
      return await action();
    } finally {
      _isShowing = false;
    }
  }
}

class _RevenueCatPaywallPresenter implements PaywallPresenter {
  const _RevenueCatPaywallPresenter();

  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {
    await PaywallPresentationGate.show(() async {
      try {
        AppAnalytics.safeLog(
          () => AppAnalytics.paywallShown(
            triggerFeature,
            defaultEntryPoint: defaultEntryPoint,
            source: source,
            launchCount: launchCount,
          ),
        );

        await RevenueCatUI.presentPaywallIfNeeded(offeringId);

        final customerInfo = await Purchases.getCustomerInfo();
        if (customerInfo.entitlements.active.isNotEmpty) {
          AppAnalytics.safeLog(
            () => AppAnalytics.purchaseCompleted(
              purchaseSource,
              defaultEntryPoint: defaultEntryPoint,
            ),
          );
        }
      } catch (e, st) {
        AppAnalytics.safeLog(
          () => AppAnalytics.log(
            'paywall_present_error',
            params: {'error': e.toString(), 'stack': st.toString()},
          ),
        );
      }
    });
  }
}
