import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/update_checker_provider.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

import '../../test_support/fake_purchases_gateway.dart';

typedef IntegrationHarnessSeed =
    Future<void> Function(IntegrationTestHarness harness);

class IntegrationTestHarness {
  IntegrationTestHarness._({
    required this.container,
    required this.database,
    required this.sharedPreferences,
    required this.purchasesGateway,
    required this.previousAnalyticsService,
  });

  final ProviderContainer container;
  final Database database;
  final SharedPreferences sharedPreferences;
  final PurchasesGateway purchasesGateway;
  final AnalyticsService previousAnalyticsService;

  static Future<IntegrationTestHarness> free({
    IntegrationHarnessSeed? seed,
    List<dynamic> overrides = const [],
  }) {
    return _create(
      purchasesGateway: FakePurchasesGateway.free(),
      seed: seed,
      additionalOverrides: overrides,
    );
  }

  static Future<IntegrationTestHarness> premium({
    IntegrationHarnessSeed? seed,
    List<dynamic> overrides = const [],
  }) {
    return _create(
      purchasesGateway: FakePurchasesGateway.premium(),
      seed: seed,
      additionalOverrides: overrides,
    );
  }

  static Future<IntegrationTestHarness> _create({
    required PurchasesGateway purchasesGateway,
    IntegrationHarnessSeed? seed,
    List<dynamic> additionalOverrides = const [],
  }) async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.withData({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final database = await databaseFactoryMemory.openDatabase(
      'integration_${DateTime.now().microsecondsSinceEpoch}.db',
    );

    final previousAnalyticsService = AppAnalytics.service;
    AppAnalytics.service = _NoopAnalyticsService();

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        premiumLocalStoreProvider.overrideWithValue(
          SharedPrefsPremiumLocalStore(sharedPreferences),
        ),
        purchasesGatewayProvider.overrideWithValue(purchasesGateway),
        paywallPresenterProvider.overrideWithValue(_NoopPaywallPresenter()),
        currentAnnouncementProvider.overrideWith((ref) async => null),
        updateAvailabilityLookupProvider.overrideWithValue(
          ({
            required String currentVersion,
            required TargetPlatform platform,
          }) async => const UpdateAvailabilityResult.unavailable(),
        ),
        ...additionalOverrides,
      ],
    );

    final harness = IntegrationTestHarness._(
      container: container,
      database: database,
      sharedPreferences: sharedPreferences,
      purchasesGateway: purchasesGateway,
      previousAnalyticsService: previousAnalyticsService,
    );

    await harness.seedSettings(GeneralSettingsModel.initial());

    if (seed != null) {
      await seed(harness);
    }

    return harness;
  }

  Future<void> dispose() async {
    container.dispose();
    purchasesGateway.dispose();
    AppAnalytics.service = previousAnalyticsService;
    await database.close();
  }

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await settleApp(tester);
    await waitForPremiumStateReady(tester);
  }

  Widget buildApp() {
    return UncontrolledProviderScope(container: container, child: const App());
  }

  Future<void> settleApp(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  }

  Future<void> waitForPremiumStateReady(WidgetTester tester) async {
    const timeout = Duration(seconds: 5);
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (!container.read(premiumStateProvider).isLoading) {
        return;
      }

      await tester.pump(const Duration(milliseconds: 100));
    }

    fail(
      'Timed out waiting for premiumStateProvider to leave loading state after ${timeout.inSeconds}s.',
    );
  }

  Future<void> seedSettings(GeneralSettingsModel settings) async {
    await container.read(settingsRepositoryProvider).saveSettings(settings);
  }

  Future<void> seedPrinters(List<PrinterModel> printers) async {
    final store = stringMapStoreFactory.store(DBName.printers.name);
    for (final printer in printers) {
      await store.record(printer.id).put(database, printer.toMap());
    }
  }

  Future<void> seedMaterials(List<MaterialModel> materials) async {
    final store = stringMapStoreFactory.store(DBName.materials.name);
    for (final material in materials) {
      await store.record(material.id).put(database, material.toMap());
    }
  }

  Future<void> seedHistory(List<HistoryModel> entries) async {
    final repository = container.read(historyRepositoryProvider);
    for (final entry in entries) {
      await repository.saveHistory(entry);
    }
  }
}

class _NoopAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {}
}

class _NoopPaywallPresenter implements PaywallPresenter {
  @override
  Future<void> present(
    String offeringId, {
    required String triggerFeature,
    required String purchaseSource,
    String defaultEntryPoint = 'manual',
    String source = 'unknown',
    int? launchCount,
  }) async {}
}

extension IntegrationHarnessWidgetTesterX on WidgetTester {
  Future<void> launchHarnessApp(IntegrationTestHarness harness) {
    return harness.launchApp(this);
  }
}
