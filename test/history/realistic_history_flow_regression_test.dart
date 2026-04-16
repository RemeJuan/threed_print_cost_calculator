import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

import '../helpers/helpers.dart';
import '../helpers/lower_level_test_fakes.dart';

const historyCsvHeader =
    'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total';

final _historyStore = StoreRef<Object?, Map<String, dynamic>>('history');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(setupTest);

  group('Realistic calculator to history regression', () {
    test(
      'single-material fallback path stays stable from calculator to history',
      () async {
        const settings = GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '120',
          activePrinter: 'printer-fallback',
          selectedMaterial: 'mat-fallback',
          wearAndTear: '0',
          failureRisk: '0',
          labourRate: '0',
        );
        final printers = {
          'printer-fallback': const PrinterModel(
            id: 'printer-fallback',
            name: 'Prusa Mini+',
            bedSize: '180x180',
            wattage: '120',
            archived: false,
          ),
        };
        final materials = {
          'mat-fallback': const MaterialModel(
            id: 'mat-fallback',
            name: 'PLA Marble',
            cost: '15.53',
            color: '#D9D9D9',
            weight: '750',
            archived: false,
          ),
        };

        final calculation = await _runCalculation(
          settings: settings,
          printers: printers,
          materials: materials,
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
        expect(calculation.results.labour, 0.0);
        expect(calculation.results.risk, 0.0);
        expect(calculation.results.total, 0.33);

        final savedModel = HistoryModel(
          name: 'Fallback 0.33',
          electricityCost: 0.04,
          filamentCost: 0.29,
          totalCost: 0.33,
          riskCost: 0,
          labourCost: 0,
          date: DateTime.utc(2024, 4, 15, 12),
          printer: 'Prusa Mini+',
          material: 'PLA Marble',
          weight: 14,
          materialUsages: [
            {
              'materialId': 'mat-fallback',
              'materialName': 'PLA Marble',
              'costPerKg': (15.53 / 750) * 1000,
              'weightGrams': 14,
            },
          ],
          timeHours: '01:00',
        );
        expect(savedModel.electricityCost, 0.04);
        expect(savedModel.filamentCost, 0.29);
        expect(savedModel.totalCost, 0.33);
        expect(savedModel.weight, 14);
        expect(savedModel.timeHours, '01:00');
        expect(savedModel.printer, 'Prusa Mini+');
        expect(savedModel.material, 'PLA Marble');
        expect(savedModel.materialUsages, [
          {
            'materialId': 'mat-fallback',
            'materialName': 'PLA Marble',
            'costPerKg': (15.53 / 750) * 1000,
            'weightGrams': 14,
          },
        ]);

        final stored = await _storeAndReadHistory(savedModel);
        expect(stored.raw['electricityCost'], 0.04);
        expect(stored.raw['filamentCost'], 0.29);
        expect(stored.raw['labourCost'], 0.0);
        expect(stored.raw['riskCost'], 0.0);
        expect(stored.raw['totalCost'], 0.33);
        expect(stored.raw['weight'], 14);
        expect(stored.raw['timeHours'], '01:00');
        expect(stored.raw['materialUsages'], savedModel.materialUsages);
        expect(stored.entry.model.filamentCost, 0.29);
        expect(stored.entry.model.totalCost, 0.33);
        expect(stored.csvLines, [
          historyCsvHeader,
          _expectedCsvRow(stored.entry.model),
        ]);
      },
    );

    test(
      'single-material initialized row stays stable for 1.77-style values',
      () async {
        const settings = GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '250',
          activePrinter: 'printer-standard',
          selectedMaterial: 'mat-standard',
          wearAndTear: '0.10',
          failureRisk: '15',
          labourRate: '2',
        );
        final printers = {
          'printer-standard': const PrinterModel(
            id: 'printer-standard',
            name: 'Prusa MK4S',
            bedSize: '250x210',
            wattage: '250',
            archived: false,
          ),
        };
        final materials = {
          'mat-standard': const MaterialModel(
            id: 'mat-standard',
            name: 'PETG Black',
            cost: '29.99',
            color: '#111111',
            weight: '1000',
            archived: false,
          ),
        };

        final calculation = await _runCalculation(
          settings: settings,
          printers: printers,
          materials: materials,
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

        expect(calculation.results.electricity, 0.12);
        expect(calculation.results.filament, 1.35);
        expect(calculation.results.labour, 0.2);
        expect(calculation.results.risk, 0.27);
        expect(calculation.results.total, 1.77);

        final savedModel = HistoryModel(
          name: 'Single 1.77',
          electricityCost: 0.12,
          filamentCost: 1.35,
          totalCost: 1.77,
          riskCost: 0.27,
          labourCost: 0.2,
          date: DateTime.utc(2024, 4, 15, 12),
          printer: 'Prusa MK4S',
          material: 'PETG Black',
          weight: 45,
          materialUsages: [
            const MaterialUsageInput(
              materialId: 'mat-standard',
              materialName: 'PETG Black',
              costPerKg: 29.99,
              weightGrams: 45,
            ).toMap(),
          ],
          timeHours: '01:30',
        );
        expect(savedModel.materialUsages, [
          const MaterialUsageInput(
            materialId: 'mat-standard',
            materialName: 'PETG Black',
            costPerKg: 29.99,
            weightGrams: 45,
          ).toMap(),
        ]);

        final stored = await _storeAndReadHistory(savedModel);
        expect(stored.raw['electricityCost'], 0.12);
        expect(stored.raw['filamentCost'], 1.35);
        expect(stored.raw['labourCost'], 0.2);
        expect(stored.raw['riskCost'], 0.27);
        expect(stored.raw['totalCost'], 1.77);
        expect(stored.raw['weight'], 45);
        expect(stored.raw['timeHours'], '01:30');
        expect(stored.entry.model.filamentCost, 1.35);
        expect(stored.entry.model.totalCost, 1.77);
        expect(stored.csvLines, [
          historyCsvHeader,
          _expectedCsvRow(stored.entry.model),
        ]);
      },
    );

    test(
      'multi-material control stays stable from calculator to history',
      () async {
        const settings = GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '120',
          activePrinter: 'printer-multi',
          selectedMaterial: '',
          wearAndTear: '0',
          failureRisk: '0',
          labourRate: '0',
        );
        final printers = {
          'printer-multi': const PrinterModel(
            id: 'printer-multi',
            name: 'Bambu Lab A1 Mini',
            bedSize: '180x180',
            wattage: '120',
            archived: false,
          ),
        };

        final calculation = await _runCalculation(
          settings: settings,
          printers: printers,
          arrange: (notifier) async {
            notifier
              ..updateWatt('120')
              ..updateKwCost('0.32')
              ..updatePrintWeight('13')
              ..updateHours(1)
              ..updateMinutes(0)
              ..addMaterialUsage(
                const MaterialUsageInput(
                  materialId: 'mat-a',
                  materialName: 'PLA Black',
                  costPerKg: 20,
                  weightGrams: 9,
                ),
              )
              ..addMaterialUsage(
                const MaterialUsageInput(
                  materialId: 'mat-b',
                  materialName: 'PLA White',
                  costPerKg: 27.5,
                  weightGrams: 4,
                ),
              )
              ..submit();
          },
        );

        expect(calculation.results.electricity, 0.04);
        expect(calculation.results.filament, 0.29);
        expect(calculation.results.total, 0.33);

        final savedModel = HistoryModel(
          name: 'Multi 0.33',
          electricityCost: 0.04,
          filamentCost: 0.29,
          totalCost: 0.33,
          riskCost: 0,
          labourCost: 0,
          date: DateTime.utc(2024, 4, 15, 12),
          printer: 'Bambu Lab A1 Mini',
          material: 'PLA Black +1',
          weight: 13,
          materialUsages: [
            const MaterialUsageInput(
              materialId: 'mat-a',
              materialName: 'PLA Black',
              costPerKg: 20,
              weightGrams: 9,
            ).toMap(),
            const MaterialUsageInput(
              materialId: 'mat-b',
              materialName: 'PLA White',
              costPerKg: 27.5,
              weightGrams: 4,
            ).toMap(),
          ],
          timeHours: '01:00',
        );
        expect(savedModel.material, 'PLA Black +1');
        expect(savedModel.weight, 13);
        expect(savedModel.materialUsages, [
          const MaterialUsageInput(
            materialId: 'mat-a',
            materialName: 'PLA Black',
            costPerKg: 20,
            weightGrams: 9,
          ).toMap(),
          const MaterialUsageInput(
            materialId: 'mat-b',
            materialName: 'PLA White',
            costPerKg: 27.5,
            weightGrams: 4,
          ).toMap(),
        ]);

        final stored = await _storeAndReadHistory(savedModel);
        expect(stored.raw['filamentCost'], 0.29);
        expect(stored.raw['totalCost'], 0.33);
        expect(stored.entry.model.filamentCost, 0.29);
        expect(stored.entry.model.totalCost, 0.33);
        expect(stored.csvLines, [
          historyCsvHeader,
          _expectedCsvRow(stored.entry.model),
        ]);
      },
    );
  });

  group('Legacy history shapes', () {
    test(
      'recomputes_legacy_single_material_history_without_zeroing_filament_cost',
      () async {
        final legacy = await _storeLegacyRecord({
          'name': 'Legacy 1.77',
          'totalCost': 1.77,
          'riskCost': 0.27,
          'filamentCost': 1.35,
          'electricityCost': 0.12,
          'labourCost': 0.2,
          'date': DateTime.utc(2024, 4, 15, 12).toIso8601String(),
          'printer': 'Prusa MK4S',
          'material': 'PETG Black',
          'weight': 45,
          'materialUsages': const [
            {
              'materialId': 'mat-legacy',
              'materialName': 'PETG Black',
              'costPerKg': 0,
              'weightGrams': 45,
            },
          ],
          'timeHours': '01:30',
        });

        expect(legacy.entry.model.filamentCost, 1.35);
        expect(legacy.entry.model.totalCost, 1.77);
        expect(legacy.entry.model.materialUsages.single['costPerKg'], 0);
        expect(legacy.csvLines, [
          historyCsvHeader,
          _expectedCsvRow(legacy.entry.model),
        ]);

        final db = await databaseFactoryMemory.openDatabase(
          'legacy_recalc_${DateTime.now().microsecondsSinceEpoch}.db',
        );
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            calculatorPreferencesRepositoryProvider.overrideWithValue(
              _FakeCalculatorPreferencesRepository(),
            ),
            settingsRepositoryProvider.overrideWithValue(
              FakeSettingsRepository(
                initialSettings: const GeneralSettingsModel(
                  electricityCost: '0.32',
                  wattage: '250',
                  activePrinter: 'printer-legacy',
                  selectedMaterial: 'mat-legacy',
                  wearAndTear: '0.10',
                  failureRisk: '15',
                  labourRate: '2',
                ),
              ),
            ),
            printersRepositoryProvider.overrideWithValue(
              FakePrintersRepository({
                'printer-legacy': const PrinterModel(
                  id: 'printer-legacy',
                  name: 'Prusa MK4S',
                  bedSize: '250x210',
                  wattage: '250',
                  archived: false,
                ),
              }),
            ),
            materialsRepositoryProvider.overrideWithValue(
              FakeMaterialsRepository({
                'mat-legacy': const MaterialModel(
                  id: 'mat-legacy',
                  name: 'PETG Black',
                  cost: '29.99',
                  color: '#111111',
                  weight: '1000',
                  archived: false,
                ),
              }),
            ),
          ],
        );

        try {
          final notifier = container.read(calculatorProvider.notifier);
          await notifier.init();

          expect(await notifier.loadFromHistory(legacy.entry), isTrue);

          final loadedState = container.read(calculatorProvider);
          expect(
            loadedState.materialUsages.single.costPerKg,
            closeTo(29.99, 0.01),
          );
          expect(loadedState.results.filament, closeTo(1.35, 0.01));

          notifier
            ..updateMinutes(45)
            ..submit();

          final recalculatedState = container.read(calculatorProvider);
          expect(recalculatedState.results.filament, closeTo(1.35, 0.01));
          expect(recalculatedState.results.total, closeTo(1.59, 0.01));

          final timeHours =
              '${recalculatedState.hours.value!.toInt().toString().padLeft(2, '0')}:${recalculatedState.minutes.value!.toInt().toString().padLeft(2, '0')}';
          final savedModel = legacy.entry.model.copyWith(
            electricityCost: recalculatedState.results.electricity,
            filamentCost: recalculatedState.results.filament,
            riskCost: recalculatedState.results.risk,
            labourCost: recalculatedState.results.labour,
            totalCost: recalculatedState.results.total,
            weight:
                recalculatedState.printWeight.value ??
                legacy.entry.model.weight,
            timeHours: timeHours,
            materialUsages: recalculatedState.materialUsages
                .map((usage) => usage.toMap())
                .toList(),
          );

          final savedKey = await container
              .read(historyRepositoryProvider)
              .saveHistory(savedModel);
          final persisted = (await _historyStore.record(savedKey).get(db))!;

          expect(
            (persisted['materialUsages'] as List).single['costPerKg'],
            closeTo(29.99, 0.01),
          );
          expect(persisted['filamentCost'], closeTo(1.35, 0.01));
          expect(persisted['totalCost'], closeTo(1.59, 0.01));
        } finally {
          container.dispose();
          await db.close();
        }
      },
    );

    test(
      'empty single-material legacy breakdown preserves history export but cannot load into calculator',
      () async {
        final legacy = await _storeLegacyRecord({
          'name': 'Legacy Empty Breakdown',
          'totalCost': 0.33,
          'riskCost': 0.0,
          'filamentCost': 0.29,
          'electricityCost': 0.04,
          'labourCost': 0.0,
          'date': DateTime.utc(2024, 4, 14, 12).toIso8601String(),
          'printer': 'Prusa Mini+',
          'material': 'PLA Marble',
          'weight': 14,
          'timeHours': '01:00',
        });

        expect(legacy.entry.model.materialUsages, isEmpty);
        expect(legacy.entry.model.filamentCost, 0.29);
        expect(legacy.entry.model.totalCost, 0.33);
        expect(legacy.csvLines, [
          historyCsvHeader,
          _expectedCsvRow(legacy.entry.model),
        ]);

        final loadResult = await _tryLoadLegacy(
          entry: legacy.entry,
          settings: GeneralSettingsModel.initial(),
        );
        expect(loadResult, isFalse);
      },
    );
  });

  group('Rendered values', () {
    testWidgets('save form builds fallback single-material payload', (
      tester,
    ) async {
      const settings = GeneralSettingsModel(
        electricityCost: '0.32',
        wattage: '120',
        activePrinter: 'printer-fallback',
        selectedMaterial: 'mat-fallback',
        wearAndTear: '0',
        failureRisk: '0',
        labourRate: '0',
      );
      final printers = {
        'printer-fallback': const PrinterModel(
          id: 'printer-fallback',
          name: 'Prusa Mini+',
          bedSize: '180x180',
          wattage: '120',
          archived: false,
        ),
      };
      final materials = {
        'mat-fallback': const MaterialModel(
          id: 'mat-fallback',
          name: 'PLA Marble',
          cost: '15.53',
          color: '#D9D9D9',
          weight: '750',
          archived: false,
        ),
      };

      final savedModel = await _captureSavedModel(
        tester,
        state: CalculatorState(
          printWeight: const NumberInput.dirty(value: 14),
          hours: const NumberInput.dirty(value: 1),
          minutes: const NumberInput.dirty(value: 0),
        ),
        results: const CalculationResult(
          electricity: 0.04,
          filament: 0.29,
          risk: 0,
          labour: 0,
          total: 0.33,
        ),
        name: 'Fallback 0.33',
        settings: settings,
        printers: printers,
        materials: materials,
      );

      expect(savedModel.printer, 'Prusa Mini+');
      expect(savedModel.material, 'PLA Marble');
      expect(savedModel.weight, 14);
      expect(savedModel.timeHours, '01:00');
      expect(savedModel.materialUsages, [
        {
          'materialId': 'mat-fallback',
          'materialName': 'PLA Marble',
          'costPerKg': (15.53 / 750) * 1000,
          'weightGrams': 14,
        },
      ]);
    });

    testWidgets('save form keeps initialized single-row payload', (
      tester,
    ) async {
      final savedModel = await _captureSavedModel(
        tester,
        state: CalculatorState(
          materialUsages: const [
            MaterialUsageInput(
              materialId: 'mat-standard',
              materialName: 'PETG Black',
              costPerKg: 29.99,
              weightGrams: 45,
            ),
          ],
          hours: const NumberInput.dirty(value: 1),
          minutes: const NumberInput.dirty(value: 30),
        ),
        results: const CalculationResult(
          electricity: 0.12,
          filament: 1.35,
          risk: 0.27,
          labour: 0.2,
          total: 1.77,
        ),
        name: 'Single 1.77',
        settings: const GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '250',
          activePrinter: 'printer-standard',
          selectedMaterial: 'mat-standard',
          wearAndTear: '0.10',
          failureRisk: '15',
          labourRate: '2',
        ),
        printers: {
          'printer-standard': const PrinterModel(
            id: 'printer-standard',
            name: 'Prusa MK4S',
            bedSize: '250x210',
            wattage: '250',
            archived: false,
          ),
        },
        materials: {
          'mat-standard': const MaterialModel(
            id: 'mat-standard',
            name: 'PETG Black',
            cost: '29.99',
            color: '#111111',
            weight: '1000',
            archived: false,
          ),
        },
      );

      expect(savedModel.material, 'PETG Black');
      expect(savedModel.materialUsages, [
        const MaterialUsageInput(
          materialId: 'mat-standard',
          materialName: 'PETG Black',
          costPerKg: 29.99,
          weightGrams: 45,
        ).toMap(),
      ]);
    });

    testWidgets('save form keeps multi-material payload', (tester) async {
      final savedModel = await _captureSavedModel(
        tester,
        state: CalculatorState(
          materialUsages: const [
            MaterialUsageInput(
              materialId: 'mat-a',
              materialName: 'PLA Black',
              costPerKg: 20,
              weightGrams: 9,
            ),
            MaterialUsageInput(
              materialId: 'mat-b',
              materialName: 'PLA White',
              costPerKg: 27.5,
              weightGrams: 4,
            ),
          ],
          hours: const NumberInput.dirty(value: 1),
          minutes: const NumberInput.dirty(value: 0),
        ),
        results: const CalculationResult(
          electricity: 0.04,
          filament: 0.29,
          risk: 0,
          labour: 0,
          total: 0.33,
        ),
        name: 'Multi 0.33',
        settings: const GeneralSettingsModel(
          electricityCost: '0.32',
          wattage: '120',
          activePrinter: 'printer-multi',
          selectedMaterial: '',
          wearAndTear: '0',
          failureRisk: '0',
          labourRate: '0',
        ),
        printers: {
          'printer-multi': const PrinterModel(
            id: 'printer-multi',
            name: 'Bambu Lab A1 Mini',
            bedSize: '180x180',
            wattage: '120',
            archived: false,
          ),
        },
      );

      expect(savedModel.material, 'PLA Black +1');
      expect(savedModel.weight, 13);
      expect(savedModel.materialUsages, [
        const MaterialUsageInput(
          materialId: 'mat-a',
          materialName: 'PLA Black',
          costPerKg: 20,
          weightGrams: 9,
        ).toMap(),
        const MaterialUsageInput(
          materialId: 'mat-b',
          materialName: 'PLA White',
          costPerKg: 27.5,
          weightGrams: 4,
        ).toMap(),
      ]);
    });

    testWidgets('calculator results shows 0.33-style values', (tester) async {
      final view = await _pumpCalculatorResults(
        tester,
        const CalculationResult(
          electricity: 0.04,
          filament: 0.29,
          risk: 0,
          labour: 0,
          total: 0.33,
        ),
      );

      expect(view['electricity'], '0.04');
      expect(view['filament'], '0.29');
      expect(view['labour'], '0');
      expect(view['risk'], '0');
      expect(view['total'], '0.33');
    });

    testWidgets('history item shows stored single-material values', (
      tester,
    ) async {
      final view = await _pumpHistoryItem(
        tester,
        HistoryModel(
          name: 'Fallback 0.33',
          electricityCost: 0.04,
          filamentCost: 0.29,
          totalCost: 0.33,
          riskCost: 0,
          labourCost: 0,
          date: DateTime.utc(2024, 4, 15, 12),
          printer: 'Prusa Mini+',
          material: 'PLA Marble',
          weight: 14,
          materialUsages: [
            {
              'materialId': 'mat-fallback',
              'materialName': 'PLA Marble',
              'costPerKg': (15.53 / 750) * 1000,
              'weightGrams': 14,
            },
          ],
          timeHours: '01:00',
        ),
        materials: {
          'mat-fallback': const MaterialModel(
            id: 'mat-fallback',
            name: 'PLA Marble',
            cost: '15.53',
            color: '#D9D9D9',
            weight: '750',
            archived: false,
          ),
        },
      );

      expect(view['electricity'], '0.04');
      expect(view['filament'], '0.29');
      expect(view['labour'], '0.00');
      expect(view['risk'], '0.00');
      expect(view['total'], '0.33');
    });

    testWidgets('history item keeps stored legacy zero-cost snapshot', (
      tester,
    ) async {
      final view = await _pumpHistoryItem(
        tester,
        HistoryModel(
          name: 'Legacy 1.77',
          electricityCost: 0.12,
          filamentCost: 1.35,
          totalCost: 1.77,
          riskCost: 0.27,
          labourCost: 0.2,
          date: DateTime.utc(2024, 4, 15, 12),
          printer: 'Prusa MK4S',
          material: 'PETG Black',
          weight: 45,
          materialUsages: const [
            {
              'materialId': 'mat-legacy',
              'materialName': 'PETG Black',
              'costPerKg': 0,
              'weightGrams': 45,
            },
          ],
          timeHours: '01:30',
        ),
      );

      expect(view['electricity'], '0.12');
      expect(view['filament'], '1.35');
      expect(view['labour'], '0.20');
      expect(view['risk'], '0.27');
      expect(view['total'], '1.77');
    });
  });
}

class _CalculationSnapshot {
  const _CalculationSnapshot({required this.state, required this.results});

  final CalculatorState state;
  final CalculationResult results;
}

class _StoredHistoryEvidence {
  const _StoredHistoryEvidence({
    required this.raw,
    required this.entry,
    required this.csvLines,
  });

  final Map<String, dynamic> raw;
  final HistoryEntry entry;
  final List<String> csvLines;
}

class _FakeCalculatorPreferencesRepository
    implements CalculatorPreferencesRepository {
  _FakeCalculatorPreferencesRepository();

  final Map<String, String> _values = {};

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<String> getStringValue(String key) async => _values[key] ?? '';

  @override
  Future<void> saveStringValue(String key, String value) async {
    _values[key] = value;
  }
}

Future<_CalculationSnapshot> _runCalculation({
  required GeneralSettingsModel settings,
  Map<String, PrinterModel> printers = const {},
  Map<String, MaterialModel> materials = const {},
  required Future<void> Function(CalculatorProvider notifier) arrange,
  bool init = false,
}) async {
  final db = await databaseFactoryMemory.openDatabase(
    'calc_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      calculatorPreferencesRepositoryProvider.overrideWithValue(
        _FakeCalculatorPreferencesRepository(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        FakeSettingsRepository(initialSettings: settings),
      ),
      printersRepositoryProvider.overrideWithValue(
        FakePrintersRepository(printers),
      ),
      materialsRepositoryProvider.overrideWithValue(
        FakeMaterialsRepository(materials),
      ),
    ],
  );

  try {
    final notifier = container.read(calculatorProvider.notifier);
    if (init) {
      await notifier.init();
    }
    await arrange(notifier);
    final state = container.read(calculatorProvider);
    return _CalculationSnapshot(state: state, results: state.results);
  } finally {
    container.dispose();
    await db.close();
  }
}

Future<HistoryModel> _captureSavedModel(
  WidgetTester tester, {
  required CalculatorState state,
  required CalculationResult results,
  required String name,
  required GeneralSettingsModel settings,
  Map<String, PrinterModel> printers = const {},
  Map<String, MaterialModel> materials = const {},
}) async {
  final settingsRepo = FakeSettingsRepository(initialSettings: settings);
  final printersRepo = FakePrintersRepository(printers);
  final materialsRepo = FakeMaterialsRepository(materials);
  final helpers = FakeCalculatorHelpers();

  final db = await tester
      .pumpApp(SaveForm(data: results, showSave: ValueNotifier<bool>(true)), [
        calculatorProvider.overrideWith(
          () => FakeCalculatorNotifier(initialState: state),
        ),
        settingsRepositoryProvider.overrideWithValue(settingsRepo),
        printersRepositoryProvider.overrideWithValue(printersRepo),
        materialsRepositoryProvider.overrideWithValue(materialsRepo),
        calculatorHelpersProvider.overrideWithValue(helpers),
      ]);

  try {
    await tester.pumpAndSettle();
    tester
        .widget<TextField>(
          find.byKey(const ValueKey<String>('calculator.save.name.input')),
        )
        .onChanged
        ?.call(name);
    await tester.pump();
    tester
        .widget<IconButton>(
          find.byKey(const ValueKey<String>('calculator.save.confirm.button')),
        )
        .onPressed
        ?.call();
    await tester.pump();

    return helpers.lastSavedPrint!;
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await db.close();
  }
}

Future<_StoredHistoryEvidence> _storeAndReadHistory(HistoryModel model) async {
  final db = await databaseFactoryMemory.openDatabase(
    'history_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );

  try {
    final historyRepository = container.read(historyRepositoryProvider);
    final csvUtils = container.read(csvUtilsProvider);
    final key = await historyRepository.saveHistory(model);
    final raw = (await _historyStore.record(key).get(db))!;
    final entry = (await historyRepository.getAllHistory()).single;
    final csv = await csvUtils.queryHistory(ExportRange.all);
    return _StoredHistoryEvidence(
      raw: raw,
      entry: entry,
      csvLines: csvUtils
          .generateCsvForItems(csv, historyCsvHeader)
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList(),
    );
  } finally {
    container.dispose();
    await db.close();
  }
}

Future<_StoredHistoryEvidence> _storeLegacyRecord(
  Map<String, dynamic> raw,
) async {
  final db = await databaseFactoryMemory.openDatabase(
    'legacy_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );

  try {
    await _historyStore.add(db, raw);
    final historyRepository = container.read(historyRepositoryProvider);
    final csvUtils = container.read(csvUtilsProvider);
    final entry = (await historyRepository.getAllHistory()).single;
    final csv = await csvUtils.queryHistory(ExportRange.all);
    return _StoredHistoryEvidence(
      raw: raw,
      entry: entry,
      csvLines: csvUtils
          .generateCsvForItems(csv, historyCsvHeader)
          .split('\n')
          .where((line) => line.isNotEmpty)
          .toList(),
    );
  } finally {
    container.dispose();
    await db.close();
  }
}

Future<bool> _tryLoadLegacy({
  required HistoryEntry entry,
  required GeneralSettingsModel settings,
}) async {
  final db = await databaseFactoryMemory.openDatabase(
    'legacy_load_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      calculatorPreferencesRepositoryProvider.overrideWithValue(
        _FakeCalculatorPreferencesRepository(),
      ),
      settingsRepositoryProvider.overrideWithValue(
        FakeSettingsRepository(initialSettings: settings),
      ),
    ],
  );

  try {
    return container.read(calculatorProvider.notifier).loadFromHistory(entry);
  } finally {
    container.dispose();
    await db.close();
  }
}

Future<Map<String, String>> _pumpCalculatorResults(
  WidgetTester tester,
  CalculationResult results,
) async {
  final db = await tester.pumpApp(CalculatorResults(results: results), [
    isPremiumProvider.overrideWithValue(true),
    shouldShowProPromotionProvider.overrideWithValue(false),
  ]);

  try {
    await tester.pump();

    return {
      'electricity': _textByKey(
        tester,
        const ValueKey<String>('calculator.result.electricityCost'),
      ),
      'filament': _textByKey(
        tester,
        const ValueKey<String>('calculator.result.filamentCost'),
      ),
      'labour': _textByKey(
        tester,
        const ValueKey<String>('calculator.result.labourCost'),
      ),
      'risk': _textByKey(
        tester,
        const ValueKey<String>('calculator.result.riskCost'),
      ),
      'total': _textByKey(
        tester,
        const ValueKey<String>('calculator.result.totalCost'),
      ),
    };
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await db.close();
  }
}

Future<Map<String, String>> _pumpHistoryItem(
  WidgetTester tester,
  HistoryModel model, {
  Map<String, MaterialModel> materials = const {},
}) async {
  final db = await tester
      .pumpApp(HistoryItem(dbKey: 'history-1', data: model), [
        materialsRepositoryProvider.overrideWithValue(
          FakeMaterialsRepository(materials),
        ),
      ]);

  try {
    await tester.pump();

    final prefix = 'history.item.${model.name}';
    return {
      'electricity': _textByKey(
        tester,
        ValueKey<String>('$prefix.electricityCost'),
      ),
      'filament': _textByKey(tester, ValueKey<String>('$prefix.filamentCost')),
      'labour': _textByKey(tester, ValueKey<String>('$prefix.labourCost')),
      'risk': _textByKey(tester, ValueKey<String>('$prefix.riskCost')),
      'total': _textByKey(tester, ValueKey<String>('$prefix.totalCost')),
    };
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    await db.close();
  }
}

String _textByKey(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data!;
}

String _expectedCsvRow(HistoryModel item) {
  final materials = item.materialUsages
      .map((usage) => '${usage['materialName']}:${usage['weightGrams']}g')
      .join('; ');
  return '"${item.date.toIso8601String()}",'
      '"${item.printer}",'
      '"${item.material}",'
      '"$materials",'
      '"${item.weight}",'
      '"${item.timeHours}",'
      '"${item.electricityCost}",'
      '"${item.filamentCost}",'
      '"${item.labourCost}",'
      '"${item.riskCost}",'
      '"${item.totalCost}"';
}
