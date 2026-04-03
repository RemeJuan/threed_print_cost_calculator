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
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

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

  static Future<IntegrationTestHarness> free({IntegrationHarnessSeed? seed}) {
    return _create(purchasesGateway: FakePurchasesGateway.free(), seed: seed);
  }

  static Future<IntegrationTestHarness> premium({
    IntegrationHarnessSeed? seed,
  }) {
    return _create(
      purchasesGateway: FakePurchasesGateway.premium(),
      seed: seed,
    );
  }

  static Future<IntegrationTestHarness> _create({
    required PurchasesGateway purchasesGateway,
    IntegrationHarnessSeed? seed,
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
        purchasesGatewayProvider.overrideWithValue(purchasesGateway),
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
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await settleApp(tester);
  }

  Future<void> settleApp(WidgetTester tester) async {
    await tester.pump();
    await tester.pumpAndSettle();
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

extension IntegrationHarnessWidgetTesterX on WidgetTester {
  Future<void> launchHarnessApp(IntegrationTestHarness harness) {
    return harness.launchApp(this);
  }
}
