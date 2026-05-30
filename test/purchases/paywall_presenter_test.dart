import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

class _FakeAnalytics implements AnalyticsService {
  final List<MapEntry<String, Map<String, Object>?>> events = [];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(MapEntry(name, params));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AnalyticsService originalAnalytics;
  late _FakeAnalytics fakeAnalytics;

  setUp(() async {
    await setupTest();
    originalAnalytics = AppAnalytics.service;
    fakeAnalytics = _FakeAnalytics();
    AppAnalytics.service = fakeAnalytics;
  });

  tearDown(() {
    AppAnalytics.service = originalAnalytics;
  });

  testWidgets('presents the custom paywall screen', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, []),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumPurchaseGatewayProvider.overrideWithValue(gateway),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: appNavigatorKey,
          home: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final presenter = container.read(paywallPresenterProvider);
    final future = presenter.present(
      'pro',
      triggerFeature: 'history',
      purchaseSource: 'history_export',
      defaultEntryPoint: 'manual',
      source: 'history_export',
    );

    await tester.pumpAndSettle();

    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(fakeAnalytics.events.first.key, 'paywall_viewed');
    expect(fakeAnalytics.events.first.value?['feature'], 'history');
    expect(fakeAnalytics.events.first.value?['source'], 'history_export');

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await future;
  });
}
