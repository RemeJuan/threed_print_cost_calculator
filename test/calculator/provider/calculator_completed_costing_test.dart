import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';

class _NoopLogSink extends AppLogSink {
  const _NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

void main() {
  late Database db;
  late ProviderContainer container;
  late InMemoryPremiumLocalStore premiumLocalStore;

  setUp(() async {
    db = await databaseFactoryMemory.openDatabase(
      'calculator_completed_costing_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    premiumLocalStore = InMemoryPremiumLocalStore();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        premiumLocalStoreProvider.overrideWithValue(premiumLocalStore),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        completedCostingTrackingDelayProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  void seedMeaningfulCostingInputs(CalculatorProvider notifier) {
    notifier.updateWatt('100');
    notifier.updateKwCost('0.5');
    notifier.updateHours(2);
    notifier.addMaterialUsage(
      const MaterialUsageInput(
        materialId: 'material-1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 100,
      ),
    );
  }

  test('tracked valid submit increments completed costing count', () async {
    final notifier = container.read(calculatorProvider.notifier);
    seedMeaningfulCostingInputs(notifier);

    notifier.submit(trackCompletedCosting: true);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(premiumLocalStore.readSync(completedCostingCountPreferenceKey), '1');
    expect(container.read(completedCostingCountProvider), 1);
  });

  test(
    'tracked invalid submit does not increment completed costing count',
    () async {
      final notifier = container.read(calculatorProvider.notifier);
      notifier.updateWatt('100');
      notifier.updateKwCost('0.5');
      notifier.updateHours(2);

      notifier.submit(trackCompletedCosting: true);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        premiumLocalStore.readSync(completedCostingCountPreferenceKey),
        isNull,
      );
      expect(container.read(completedCostingCountProvider), 0);
    },
  );

  test('rapid tracked recalculations count once after debounce', () async {
    final notifier = container.read(calculatorProvider.notifier);
    seedMeaningfulCostingInputs(notifier);

    notifier.submit(trackCompletedCosting: true);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    notifier.updateMinutes(30);
    notifier.submit(trackCompletedCosting: true);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(premiumLocalStore.readSync(completedCostingCountPreferenceKey), '1');
    expect(container.read(completedCostingCountProvider), 1);
  });

  test(
    'non-tracking submit cancels pending completed costing increment',
    () async {
      final notifier = container.read(calculatorProvider.notifier);
      seedMeaningfulCostingInputs(notifier);

      notifier.submit(trackCompletedCosting: true);
      notifier.submit();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        premiumLocalStore.readSync(completedCostingCountPreferenceKey),
        isNull,
      );
      expect(container.read(completedCostingCountProvider), 0);
    },
  );
}
