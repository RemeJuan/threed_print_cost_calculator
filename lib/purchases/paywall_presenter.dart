import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

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
  return const _AppPaywallPresenter();
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

class _AppPaywallPresenter implements PaywallPresenter {
  const _AppPaywallPresenter();

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
        final navigator = appNavigatorKey.currentState;
        if (navigator == null) {
          throw StateError('Navigator not ready');
        }

        await navigator.push<void>(
          MaterialPageRoute(
            builder: (_) => PaywallScreen(
              offeringId: offeringId,
              triggerFeature: triggerFeature,
              purchaseSource: purchaseSource,
              defaultEntryPoint: defaultEntryPoint,
              source: source,
              launchCount: launchCount,
            ),
            fullscreenDialog: true,
          ),
        );
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
