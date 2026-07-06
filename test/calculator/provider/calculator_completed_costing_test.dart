import 'package:flutter/widgets.dart';
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

class _DelayedPremiumLocalStore extends InMemoryPremiumLocalStore {
  _DelayedPremiumLocalStore({
    required this.writeDelay,
    Map<String, String>? initialValues,
  }) : super(initialValues);

  final Duration writeDelay;

  @override
  Future<void> write(String key, String value) async {
    await Future<void>.delayed(writeDelay);
    await super.write(key, value);
  }
}

class _NoopFirstWritePremiumLocalStore extends InMemoryPremiumLocalStore {
  _NoopFirstWritePremiumLocalStore();

  var _shouldSkipNextWrite = true;

  @override
  Future<void> write(String key, String value) async {
    if (_shouldSkipNextWrite) {
      _shouldSkipNextWrite = false;
      return;
    }

    await super.write(key, value);
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late Database db;
  late ProviderContainer container;
  late InMemoryPremiumLocalStore premiumLocalStore;

  setUp(() async {
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
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

  test('paused tracked submit queues completed costing until resume', () async {
    final notifier = container.read(calculatorProvider.notifier);
    seedMeaningfulCostingInputs(notifier);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    notifier.submit(trackCompletedCosting: true);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(
      premiumLocalStore.readSync(completedCostingCountPreferenceKey),
      isNull,
    );
    expect(container.read(completedCostingCountProvider), 0);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(premiumLocalStore.readSync(completedCostingCountPreferenceKey), '1');
    expect(container.read(completedCostingCountProvider), 1);
  });

  test('overlapping flush and active increment stay serialized', () async {
    final delayedStore = _DelayedPremiumLocalStore(
      writeDelay: const Duration(milliseconds: 40),
    );
    final localContainer = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        premiumLocalStoreProvider.overrideWithValue(delayedStore),
        appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
        completedCostingTrackingDelayProvider.overrideWithValue(
          const Duration(milliseconds: 10),
        ),
      ],
    );
    addTearDown(localContainer.dispose);
    final service = localContainer.read(appUsageServiceProvider);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await service.recordCompletedCosting();
    await service.recordCompletedCosting();

    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await service.recordCompletedCosting();
    await Future<void>.delayed(const Duration(milliseconds: 120));

    expect(delayedStore.readSync(completedCostingCountPreferenceKey), '3');
    expect(localContainer.read(completedCostingCountProvider), 3);
  });

  test(
    'failed flush keeps pending increments for next successful write',
    () async {
      final retryingStore = _NoopFirstWritePremiumLocalStore();
      final localContainer = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          premiumLocalStoreProvider.overrideWithValue(retryingStore),
          appLogSinkProvider.overrideWithValue(const _NoopLogSink()),
          completedCostingTrackingDelayProvider.overrideWithValue(
            const Duration(milliseconds: 10),
          ),
        ],
      );
      addTearDown(localContainer.dispose);
      final service = localContainer.read(appUsageServiceProvider);

      binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await service.recordCompletedCosting();

      binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        retryingStore.readSync(completedCostingCountPreferenceKey),
        isNull,
      );
      expect(localContainer.read(completedCostingCountProvider), 0);

      await service.recordCompletedCosting();

      expect(retryingStore.readSync(completedCostingCountPreferenceKey), '2');
      expect(localContainer.read(completedCostingCountProvider), 2);
    },
  );

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
