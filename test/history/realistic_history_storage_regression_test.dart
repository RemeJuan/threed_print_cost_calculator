import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';
import 'history_regression_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(setupTest);

  group('Realistic calculator to history regression', () {
    test(
      'single-material fallback path stays stable from calculator to history',
      () async {
        final calculation = await runCalculation(
          settings: HistoryRegressionFixtures.fallbackSettings,
          printers: HistoryRegressionFixtures.fallbackPrinters(),
          materials: HistoryRegressionFixtures.fallbackMaterials(),
          arrange: (notifier) async {
            notifier
              ..updateWatt('120')
              ..updateKwCost('0.32')
              ..updatePrintWeight('14')
              ..updateHours(1)
              ..updateMinutes(0)
              ..updateSpoolWeight(750)
              ..updateSpoolCost('15.53')
              ..submit();
          },
        );

        expect(calculation.results.electricity, 0.04);
        expect(calculation.results.filament, 0.29);
        expect(calculation.results.total, 0.33);

        final stored = await storeAndReadHistory(
          HistoryRegressionFixtures.fallbackHistoryModel(),
        );
        expect(stored.raw['filamentCost'], 0.29);
        expect(stored.raw['totalCost'], 0.33);
        expect(stored.entry.model.filamentCost, 0.29);
        expect(stored.entry.model.totalCost, 0.33);
        expectStoredHistoryCsv(stored);
      },
    );

    test(
      'single-material initialized row stays stable for 1.77-style values',
      () async {
        final calculation = await runCalculation(
          settings: HistoryRegressionFixtures.initializedSettings,
          printers: HistoryRegressionFixtures.initializedPrinters(),
          materials: HistoryRegressionFixtures.initializedMaterials(),
          init: true,
          arrange: (notifier) async {
            notifier
              ..updatePrintWeight('45')
              ..updateHours(1)
              ..updateMinutes(30)
              ..updateLabourTime(0.1)
              ..submit();
          },
        );
        expect(calculation.results.total, 2.02);

        final stored = await storeAndReadHistory(
          HistoryRegressionFixtures.initializedHistoryModel(),
        );
        expect(stored.raw['filamentCost'], 1.35);
        expect(stored.raw['totalCost'], 1.77);
        expectStoredHistoryCsv(stored);
      },
    );

    test(
      'multi-material control stays stable from calculator to history',
      () async {
        final calculation = await runCalculation(
          settings: HistoryRegressionFixtures.multiMaterialSettings,
          printers: HistoryRegressionFixtures.multiMaterialPrinters(),
          arrange: (notifier) async {
            notifier
              ..updateWatt('120')
              ..updateKwCost('0.32')
              ..updatePrintWeight('13')
              ..updateHours(1)
              ..updateMinutes(0)
              ..addMaterialUsage(
                HistoryRegressionFixtures.multiMaterialState.materialUsages[0],
              )
              ..addMaterialUsage(
                HistoryRegressionFixtures.multiMaterialState.materialUsages[1],
              )
              ..submit();
          },
        );
        expect(calculation.results.total, 0.33);

        final stored = await storeAndReadHistory(
          HistoryRegressionFixtures.multiMaterialHistoryModel(),
        );
        expect(stored.entry.model.material, 'PLA Black +1');
        expectStoredHistoryCsv(stored);
      },
    );
  });

  group('Legacy history shapes', () {
    test(
      'recomputes_legacy_single_material_history_without_zeroing_filament_cost',
      () async {
        final legacy = await storeLegacyRecord(
          HistoryRegressionFixtures.legacySingleMaterialRaw(),
        );
        expect(legacy.entry.model.filamentCost, 1.35);
        expectStoredHistoryCsv(legacy);

        final db = await databaseFactoryMemory.openDatabase(
          'legacy_recalc_${DateTime.now().microsecondsSinceEpoch}.db',
        );
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            calculatorPreferencesRepositoryProvider.overrideWithValue(
              FakeCalculatorPreferencesRepository(),
            ),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(
                initialSettings: HistoryRegressionFixtures.initializedSettings,
              ),
            ),
            printersRepositoryProvider.overrideWithValue(
              FakePrintersRepository(
                HistoryRegressionFixtures.initializedPrinters(),
              ),
            ),
            materialsRepositoryProvider.overrideWithValue(
              FakeMaterialsRepository(
                HistoryRegressionFixtures.initializedMaterials(),
              ),
            ),
          ],
        );
        try {
          final notifier = container.read(calculatorProvider.notifier);
          await notifier.init();
          expect(await notifier.loadFromHistory(legacy.entry), isTrue);
          notifier
            ..updateMinutes(45)
            ..submit();
          final recalculatedState = container.read(calculatorProvider);
          expect(recalculatedState.results.filament, closeTo(1.35, 0.01));
          expect(recalculatedState.results.total, closeTo(1.81, 0.01));
          final savedModel = legacy.entry.model.copyWith(
            electricityCost: recalculatedState.results.electricity,
            filamentCost: recalculatedState.results.filament,
            riskCost: recalculatedState.results.risk,
            labourCost: recalculatedState.results.labour,
            totalCost: recalculatedState.results.total,
            weight:
                recalculatedState.printWeight.value ??
                legacy.entry.model.weight,
            timeHours:
                '${recalculatedState.hours.value!.toInt().toString().padLeft(2, '0')}:${recalculatedState.minutes.value!.toInt().toString().padLeft(2, '0')}',
            materialUsages: recalculatedState.materialUsages
                .map((usage) => usage.toMap())
                .toList(),
          );
          final savedKey = await container
              .read(historyRepositoryProvider)
              .saveHistory(savedModel);
          final persisted = (await historyStore.record(savedKey).get(db))!;
          expect(
            (persisted['materialUsages'] as List).single['costPerKg'],
            closeTo(29.99, 0.01),
          );
        } finally {
          container.dispose();
          await db.close();
        }
      },
    );

    test(
      'empty single-material legacy breakdown preserves history export but cannot load into calculator',
      () async {
        final legacy = await storeLegacyRecord(
          HistoryRegressionFixtures.legacyEmptyBreakdownRaw(),
        );
        expect(legacy.entry.model.materialUsages, isEmpty);
        expectStoredHistoryCsv(legacy);
        expect(
          await tryLoadLegacy(
            entry: legacy.entry,
            settings: GeneralSettingsModel.initial(),
          ),
          isFalse,
        );
      },
    );
  });
}
