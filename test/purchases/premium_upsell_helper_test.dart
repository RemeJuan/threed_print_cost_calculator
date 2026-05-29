import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';

import '../helpers/lower_level_test_fakes.dart';

class _FakeAnalytics implements AnalyticsService {
  final List<MapEntry<String, Map<String, Object>?>> events = [];

  String get lastName => events.last.key;

  Map<String, Object>? get lastParams => events.last.value;

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(MapEntry(name, params));
  }
}

void main() {
  late AnalyticsService originalAnalytics;
  late _FakeAnalytics analytics;

  setUp(() {
    originalAnalytics = AppAnalytics.service;
    analytics = _FakeAnalytics();
    AppAnalytics.service = analytics;
  });

  tearDown(() {
    AppAnalytics.service = originalAnalytics;
  });

  group('requirePremium', () {
    test('returns true immediately when access is allowed', () async {
      final paywallPresenter = FakePaywallPresenter();
      final access = const FeatureAccess(
        allowed: true,
        feature: PremiumFeature.historyExport,
      );

      final result = await requirePremium(
        paywallPresenter,
        access,
        purchaseSource: 'test_source',
      );

      expect(result, true);
      expect(paywallPresenter.calls, 0);
      expect(analytics.events, isEmpty);
    });

    test('presents paywall and returns false when access is denied', () async {
      final paywallPresenter = FakePaywallPresenter();
      final access = const FeatureAccess(
        allowed: false,
        feature: PremiumFeature.historyExport,
      );

      final result = await requirePremium(
        paywallPresenter,
        access,
        purchaseSource: 'test_source',
      );

      expect(result, false);
      expect(paywallPresenter.calls, 1);
      expect(paywallPresenter.lastOfferingId, 'pro');
      expect(paywallPresenter.lastTriggerFeature, 'historyExport');
      expect(paywallPresenter.lastPurchaseSource, 'test_source');
      expect(paywallPresenter.lastSource, 'test_source');
    });

    test('logs upsell analytics when access is denied', () async {
      final paywallPresenter = FakePaywallPresenter();
      final access = const FeatureAccess(
        allowed: false,
        feature: PremiumFeature.historyExport,
      );

      final result = await requirePremium(
        paywallPresenter,
        access,
        purchaseSource: 'test_source',
      );

      expect(result, false);
      expect(analytics.lastName, 'premium_feature_tapped');
      expect(analytics.lastParams, {
        'feature': 'historyExport',
        'is_pro': 0,
        'source': 'test_source',
      });
      expect(paywallPresenter.calls, 1);
    });

    test('presents paywall with different feature name', () async {
      final paywallPresenter = FakePaywallPresenter();
      final access = const FeatureAccess(
        allowed: false,
        feature: PremiumFeature.batchExport,
      );

      final result = await requirePremium(
        paywallPresenter,
        access,
        purchaseSource: 'batch_export',
      );

      expect(result, false);
      expect(paywallPresenter.lastTriggerFeature, 'batchExport');
    });
  });
}
