import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_models.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_provider.dart';
import 'package:threed_print_cost_calculator/core/integrity/play_integrity_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_screen.dart';
import 'package:threed_print_cost_calculator/purchases/premium_purchase_gateway.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_tools_dialog.dart';

import '../helpers/helpers.dart';
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

class _AllowIntegrityService implements PlayIntegrityService {
  @override
  Future<PlayIntegritySnapshot> evaluate(PlayIntegrityFlow flow) async {
    return const PlayIntegritySnapshot(
      license: 'LICENSED',
      appIntegrity: 'PLAY_RECOGNIZED',
      deviceIntegrity: 'MEETS_DEVICE_INTEGRITY',
      virtualIntegrity: 'UNEVALUATED',
      recentDeviceActivity: 'UNEVALUATED',
      playProtect: 'NO_ISSUES',
      appAccessRisk: <String>[],
      decision: PlayIntegrityDecisionLabel.allow,
    );
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

  Future<void> pumpPaywall(
    WidgetTester tester, {
    FakePremiumPurchaseGateway? gateway,
  }) async {
    final effectiveGateway = gateway ?? FakePremiumPurchaseGateway();
    final db = await tester.pumpApp(const PaywallScreen(), [
      premiumPurchaseGatewayProvider.overrideWithValue(effectiveGateway),
      playIntegrityServiceProvider.overrideWithValue(_AllowIntegrityService()),
    ]);
    addTearDown(() => db.close());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('renders paywall screen with title and CTA', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallTitle), findsOneWidget);
    expect(find.text(l10n.paywallPitchLine), findsOneWidget);
    expect(find.byType(AppPrimaryButton), findsOneWidget);
    expect(find.text(l10n.paywallRestore), findsOneWidget);
    expect(find.text(l10n.paywallTrustLine), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('comparison table shows feature row labels', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallRowMaterialsLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowPrintersLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowHistoryLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowBatchCostingLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowAdvancedPricingLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowExportToolsLabel), findsOneWidget);
    expect(find.text(l10n.paywallRowInventoryTrackingLabel), findsOneWidget);
  });

  testWidgets('comparison table shows cell values', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallValueUnlimited), findsAtLeast(1));
    expect(find.text(l10n.paywallValueNo), findsAtLeast(1));
    expect(find.text(l10n.paywallValueBasic), findsOneWidget);
    expect(find.text(l10n.paywallValueFull), findsOneWidget);
    expect(find.text(l10n.paywallValueSingleJob), findsOneWidget);
    expect(find.text(l10n.paywallValueFullSuite), findsOneWidget);
  });

  testWidgets('plan selector renders descriptive plan rows', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'quarterly_pkg',
          PackageType.threeMonth,
          StoreProduct(
            'quarterly_sku',
            'Quarterly plan',
            'Quarterly Plan',
            4.99,
            '\$4.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
        Package(
          'annual_pkg',
          PackageType.annual,
          StoreProduct(
            'annual_sku',
            'Annual plan',
            'Annual Plan',
            9.99,
            '\$9.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
        Package(
          'lifetime_pkg',
          PackageType.lifetime,
          StoreProduct(
            'lifetime_sku',
            'Lifetime plan',
            'Lifetime Plan',
            29.99,
            '\$29.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );

    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallPlanQuarterly), findsOneWidget);
    expect(find.text(l10n.paywallPlanAnnual), findsOneWidget);
    expect(find.text(l10n.paywallPlanLifetime), findsOneWidget);
    expect(find.text(l10n.paywallPlanPriceQuarterly('\$4.99')), findsOneWidget);
    expect(find.text(l10n.paywallPlanPriceAnnual('\$9.99')), findsOneWidget);
    expect(find.text(l10n.paywallPlanPriceLifetime('\$29.99')), findsOneWidget);
    expect(find.textContaining(l10n.paywallPlanCancelAnytime), findsOneWidget);
    expect(find.textContaining(l10n.paywallPlanTrial), findsOneWidget);
    expect(find.text(l10n.paywallPlanOwnForever), findsOneWidget);
    expect(find.text(l10n.paywallBestValue), findsOneWidget);
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).label,
      contains('Trial'),
    );
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_off), findsNWidgets(2));
  });

  testWidgets('cta updates for selected package', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'quarterly_pkg',
          PackageType.threeMonth,
          StoreProduct(
            'quarterly_sku',
            'Quarterly plan',
            'Quarterly Plan',
            4.99,
            '\$4.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
        Package(
          'annual_pkg',
          PackageType.annual,
          StoreProduct(
            'annual_sku',
            'Annual plan',
            'Annual Plan',
            9.99,
            '\$9.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
        Package(
          'lifetime_pkg',
          PackageType.lifetime,
          StoreProduct(
            'lifetime_sku',
            'Lifetime plan',
            'Lifetime Plan',
            29.99,
            '\$29.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );

    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).label,
      contains('Trial'),
    );

    await tester.ensureVisible(find.textContaining(l10n.paywallPlanQuarterly));
    await tester.tap(find.textContaining(l10n.paywallPlanQuarterly));
    await tester.pump();
    expect(
      find.textContaining(l10n.paywallCtaQuarterly('\$4.99')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.textContaining(l10n.paywallPlanLifetime));
    await tester.tap(find.textContaining(l10n.paywallPlanLifetime));
    await tester.pump();
    expect(
      find.textContaining(l10n.paywallCtaLifetime('\$29.99')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.textContaining(l10n.paywallPlanAnnual));
    await tester.tap(find.textContaining(l10n.paywallPlanAnnual));
    await tester.pump();
    expect(
      tester.widget<AppPrimaryButton>(find.byType(AppPrimaryButton)).label,
      contains('Trial'),
    );
  });

  testWidgets('plan copy stays compact and localized', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'annual_pkg',
          PackageType.annual,
          StoreProduct(
            'annual_sku',
            'Annual plan',
            'Annual Plan',
            9.99,
            '\$9.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );

    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallPlanAnnual), findsOneWidget);
    expect(find.text(l10n.paywallPlanPriceAnnual('\$9.99')), findsOneWidget);
    expect(find.textContaining(l10n.paywallPlanTrial), findsOneWidget);
    expect(find.text(l10n.paywallBestValue), findsOneWidget);
  });

  testWidgets('annual package shows best value chip', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'monthly_pkg',
          PackageType.monthly,
          StoreProduct(
            'monthly_sku',
            'Monthly',
            'Monthly',
            10.0,
            '10.00',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
        Package(
          'annual_pkg',
          PackageType.annual,
          StoreProduct('annual_sku', 'Annual', 'Annual', 96.0, '96.00', 'USD'),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );

    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallBestValue), findsOneWidget);
  });

  testWidgets('annual package hides savings when no monthly comparison', (
    tester,
  ) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'annual_pkg',
          PackageType.annual,
          StoreProduct('annual_sku', 'Annual', 'Annual', 96.0, '96.00', 'USD'),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );

    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallBestValue), findsOneWidget);
    expect(find.textContaining('Save '), findsNothing);
  });

  testWidgets('batch costing row exists', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallRowBatchCostingLabel), findsOneWidget);
  });

  testWidgets('paywall shows trust row', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallTrustLine), findsOneWidget);
  });

  testWidgets('purchase calls gateway when CTA tapped', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'test_pkg',
          PackageType.monthly,
          StoreProduct(
            'test_sku',
            'A test plan',
            'Test Plan',
            9.99,
            '9.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );
    await pumpPaywall(tester, gateway: gateway);
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(gateway.purchasePackageCalls, 1);
  });

  testWidgets('restore calls gateway when restore tapped', (tester) async {
    final gateway = FakePremiumPurchaseGateway();
    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(l10n.paywallRestore));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(gateway.restorePurchasesCalls, 1);
  });

  testWidgets('close action pops the screen', (tester) async {
    await pumpPaywall(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  });

  testWidgets('analytics paywall_shown on screen load', (tester) async {
    await pumpPaywall(tester);
    expect(fakeAnalytics.lastName, 'paywall_viewed');
    expect(fakeAnalytics.lastParams?['source'], 'custom_paywall_preview');
  });

  testWidgets('analytics purchase_completed on purchase', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'test_pkg',
          PackageType.monthly,
          StoreProduct(
            'test_sku',
            'A test plan',
            'Test Plan',
            9.99,
            '\$9.99',
            'USD',
          ),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
    );
    await pumpPaywall(tester, gateway: gateway);
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      fakeAnalytics.events.any((e) => e.key == 'purchase_completed'),
      true,
    );
  });

  testWidgets('analytics restore_completed on restore', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(l10n.paywallRestore));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(fakeAnalytics.events.any((e) => e.key == 'restore_completed'), true);
  });

  testWidgets('previewCustomPaywall button exists in test tools dialog', (
    tester,
  ) async {
    final actions = <TestDataAction?>[];
    final db = await tester.pumpApp(
      TestDataToolsDialog(onAction: (action) => actions.add(action)),
    );
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    expect(find.text('Preview custom paywall'), findsOneWidget);
  });

  testWidgets('previewCustomPaywall button triggers action', (tester) async {
    final actions = <TestDataAction?>[];
    final db = await tester.pumpApp(
      TestDataToolsDialog(onAction: (action) => actions.add(action)),
    );
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    final scrollable = find.byType(SingleChildScrollView);
    await tester.dragUntilVisible(
      find.byKey(
        const ValueKey<String>('settings.testData.previewCustomPaywall.button'),
      ),
      scrollable,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.previewCustomPaywall.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(actions, [TestDataAction.previewCustomPaywall]);
  });

  testWidgets('shows empty offerings message when no packages', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('empty', 'Empty', {}, []),
    );
    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(find.text(l10n.paywallEmptyOfferings), findsOneWidget);
  });

  testWidgets('purchase error shows snackbar', (tester) async {
    final gateway = FakePremiumPurchaseGateway(
      currentOffering: Offering('test_offering', 'Test Offering', {}, [
        Package(
          'test_pkg',
          PackageType.monthly,
          StoreProduct('test_sku', 'desc', 'Plan', 9.99, '\$9.99', 'USD'),
          PresentedOfferingContext('test_offering', null, null),
        ),
      ]),
      shouldThrowOnPurchase: true,
    );
    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.byType(AppPrimaryButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(l10n.purchaseError), findsOneWidget);
  });

  testWidgets('restore success dismisses paywall', (tester) async {
    await pumpPaywall(tester);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(l10n.paywallRestore));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(l10n.paywallTitle), findsNothing);
  });

  testWidgets('restore error shows snackbar', (tester) async {
    final gateway = FakePremiumPurchaseGateway(shouldThrowOnRestore: true);
    await pumpPaywall(tester, gateway: gateway);

    final l10n = lookupAppLocalizations(const Locale('en'));
    await tester.tap(find.text(l10n.paywallRestore));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(l10n.paywallRestoreError), findsOneWidget);
  });
}
