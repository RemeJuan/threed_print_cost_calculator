import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  group('CalculatorProvider.loadFromHistory', () {
    setUpAll(setupTest);

    test('restores stored snapshot with single state emission', () async {
      final settingsRepository = FakeSettingsRepository(
        initialSettings: const GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '180',
          activePrinter: 'printer-current',
          selectedMaterial: 'material-current',
          wearAndTear: '1.5',
          failureRisk: '10',
          labourRate: '15',
        ),
      );
      final printersRepository = FakePrintersRepository({
        'printer-current': const PrinterModel(
          id: 'printer-current',
          name: 'Bambu X1C',
          bedSize: '256x256',
          wattage: '180',
          archived: false,
        ),
        'printer-history': const PrinterModel(
          id: 'printer-history',
          name: 'Prusa MK4',
          bedSize: '250x210',
          wattage: '250',
          archived: false,
        ),
      });
      final materialsRepository = FakeMaterialsRepository({
        'mat-pla': const MaterialModel(
          id: 'mat-pla',
          name: 'PLA Red',
          cost: '25',
          color: '#FF0000',
          weight: '1000',
          archived: false,
        ),
        'mat-petg': const MaterialModel(
          id: 'mat-petg',
          name: 'PETG Blue',
          cost: '30',
          color: '#0000FF',
          weight: '1000',
          archived: false,
        ),
      });

      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          printersRepositoryProvider.overrideWithValue(printersRepository),
          materialsRepositoryProvider.overrideWithValue(materialsRepository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(calculatorProvider.notifier);
      notifier.state = CalculatorState(
        materialUsages: const [
          MaterialUsageInput(
            materialId: 'material-current',
            materialName: 'Current',
            costPerKg: 99,
            weightGrams: 1,
          ),
        ],
      );

      var emissions = 0;
      final sub = container.listen<CalculatorState>(
        calculatorProvider,
        (previous, next) => emissions += 1,
        fireImmediately: false,
      );
      addTearDown(sub.close);

      final didLoad = await notifier.loadFromHistory(
        HistoryEntry(
          key: 'history-1',
          model: HistoryModel(
            name: 'Benchy',
            totalCost: 12.34,
            riskCost: 1.11,
            filamentCost: 7.89,
            electricityCost: 0.45,
            labourCost: 2.89,
            date: DateTime.utc(2024, 1, 1),
            printer: 'Prusa MK4',
            material: 'PLA Red',
            weight: 123,
            timeHours: '02:15',
            materialUsages: const [
              {
                'materialId': 'mat-pla',
                'materialName': 'PLA Red',
                'costPerKg': 25,
                'weightGrams': 100,
              },
              {
                'materialId': 'mat-petg',
                'materialName': 'PETG Blue',
                'costPerKg': 30,
                'weightGrams': 23,
              },
            ],
          ),
        ),
      );

      expect(didLoad, isTrue);
      expect(emissions, 1);

      final state = container.read(calculatorProvider);
      expect(state.watt.value, 250);
      expect(state.printWeight.value, 123);
      expect(state.hours.value, 2);
      expect(state.minutes.value, 15);
      expect(state.materialUsages, hasLength(2));
      expect(state.materialUsages.first.materialId, 'mat-pla');
      expect(state.materialUsages.last.materialId, 'mat-petg');
      expect(state.materialUsages.last.weightGrams, 23);
      expect(state.results.electricity, 0.45);
      expect(state.results.filament, 7.89);
      expect(state.results.risk, 1.11);
      expect(state.results.labour, 2.89);
      expect(state.results.total, 12.34);
      expect(state.showHistoryLoadReplacementWarning, isFalse);
      expect(
        settingsRepository.lastSavedSettings?.activePrinter,
        'printer-history',
      );
      expect(settingsRepository.lastSavedSettings?.selectedMaterial, 'mat-pla');
    });

    test(
      'falls back missing references and flags replacement warning',
      () async {
        final settingsRepository = FakeSettingsRepository(
          initialSettings: const GeneralSettingsModel(
            electricityCost: '0.32',
            wattage: '180',
            activePrinter: 'printer-current',
            selectedMaterial: 'material-current',
            wearAndTear: '1.5',
            failureRisk: '10',
            labourRate: '15',
          ),
        );
        final printersRepository = FakePrintersRepository({
          'printer-current': const PrinterModel(
            id: 'printer-current',
            name: 'Bambu X1C',
            bedSize: '256x256',
            wattage: '180',
            archived: false,
          ),
        });
        final materialsRepository = FakeMaterialsRepository({
          'mat-fallback': const MaterialModel(
            id: 'mat-fallback',
            name: 'Fallback Material',
            cost: '19',
            color: '#FFFFFF',
            weight: '1000',
            archived: false,
          ),
        });

        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(settingsRepository),
            printersRepositoryProvider.overrideWithValue(printersRepository),
            materialsRepositoryProvider.overrideWithValue(materialsRepository),
          ],
        );
        addTearDown(container.dispose);

        final notifier = container.read(calculatorProvider.notifier);

        final didLoad = await notifier.loadFromHistory(
          HistoryEntry(
            key: 'history-2',
            model: HistoryModel(
              name: 'Fallback Benchy',
              totalCost: 5,
              riskCost: 1,
              filamentCost: 2,
              electricityCost: 1,
              labourCost: 1,
              date: DateTime.utc(2024, 1, 2),
              printer: 'Missing Printer',
              material: 'Missing Material',
              weight: 40,
              timeHours: '00:45',
              materialUsages: const [
                {
                  'materialId': 'missing-material',
                  'materialName': 'Missing Material',
                  'costPerKg': 2,
                  'weightGrams': 40,
                },
              ],
            ),
          ),
        );

        expect(didLoad, isTrue);

        final state = container.read(calculatorProvider);
        expect(state.watt.value, 180);
        expect(state.materialUsages.single.materialId, 'mat-fallback');
        expect(state.materialUsages.single.materialName, 'Fallback Material');
        expect(state.materialUsages.single.costPerKg, 2);
        expect(state.materialUsages.single.weightGrams, 40);
        expect(state.showHistoryLoadReplacementWarning, isTrue);
      },
    );
  });
}
