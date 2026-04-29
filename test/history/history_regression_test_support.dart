import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
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
    'Date,Printer,Material,Materials,Weight (g),Time,Electricity,Filament,Labour,Risk,Total,Pricing Markup %,Pricing Markup,Pricing Setup Fee,Pricing Rounding,Pricing Subtotal,Pricing Rounding Adjustment,Final Price';

final historyStore = StoreRef<Object?, Map<String, dynamic>>('history');

class CalculationSnapshot {
  const CalculationSnapshot({required this.state, required this.results});

  final CalculatorState state;
  final CalculationResult results;
}

class StoredHistoryEvidence {
  const StoredHistoryEvidence({
    required this.raw,
    required this.entry,
    required this.csvLines,
  });

  final Map<String, dynamic> raw;
  final HistoryEntry entry;
  final List<String> csvLines;
}

class HistoryRegressionFixtures {
  static const fallbackSettings = GeneralSettingsModel(
    electricityCost: '0.32',
    wattage: '120',
    activePrinter: 'printer-fallback',
    selectedMaterial: 'mat-fallback',
    wearAndTear: '0',
    failureRisk: '0',
    labourRate: '0',
  );

  static const fallbackPrinter = PrinterModel(
    id: 'printer-fallback',
    name: 'Prusa Mini+',
    bedSize: '180x180',
    wattage: '120',
    archived: false,
  );

  static const fallbackMaterial = MaterialModel(
    id: 'mat-fallback',
    name: 'PLA Marble',
    cost: '15.53',
    color: '#D9D9D9',
    weight: '750',
    archived: false,
  );

  static Map<String, PrinterModel> fallbackPrinters() => {
    fallbackPrinter.id: fallbackPrinter,
  };

  static Map<String, MaterialModel> fallbackMaterials() => {
    fallbackMaterial.id: fallbackMaterial,
  };

  static const initializedSettings = GeneralSettingsModel(
    electricityCost: '0.32',
    wattage: '250',
    activePrinter: 'printer-standard',
    selectedMaterial: 'mat-standard',
    wearAndTear: '0.10',
    failureRisk: '15',
    labourRate: '2',
  );

  static const initializedPrinter = PrinterModel(
    id: 'printer-standard',
    name: 'Prusa MK4S',
    bedSize: '250x210',
    wattage: '250',
    archived: false,
  );

  static const initializedMaterial = MaterialModel(
    id: 'mat-standard',
    name: 'PETG Black',
    cost: '29.99',
    color: '#111111',
    weight: '1000',
    archived: false,
  );

  static Map<String, PrinterModel> initializedPrinters() => {
    initializedPrinter.id: initializedPrinter,
  };

  static Map<String, MaterialModel> initializedMaterials() => {
    initializedMaterial.id: initializedMaterial,
  };

  static const multiMaterialSettings = GeneralSettingsModel(
    electricityCost: '0.32',
    wattage: '120',
    activePrinter: 'printer-multi',
    selectedMaterial: '',
    wearAndTear: '0',
    failureRisk: '0',
    labourRate: '0',
  );

  static const multiMaterialPrinter = PrinterModel(
    id: 'printer-multi',
    name: 'Bambu Lab A1 Mini',
    bedSize: '180x180',
    wattage: '120',
    archived: false,
  );

  static Map<String, PrinterModel> multiMaterialPrinters() => {
    multiMaterialPrinter.id: multiMaterialPrinter,
  };

  static final multiMaterialState = CalculatorState(
    materialUsages: [
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
    hours: NumberInput.dirty(value: 1),
    minutes: NumberInput.dirty(value: 0),
  );

  static final fallbackState = CalculatorState(
    printWeight: NumberInput.dirty(value: 14),
    hours: NumberInput.dirty(value: 1),
    minutes: NumberInput.dirty(value: 0),
  );

  static final initializedState = CalculatorState(
    materialUsages: [
      MaterialUsageInput(
        materialId: 'mat-standard',
        materialName: 'PETG Black',
        costPerKg: 29.99,
        weightGrams: 45,
      ),
    ],
    hours: NumberInput.dirty(value: 1),
    minutes: NumberInput.dirty(value: 30),
  );

  static const fallbackResults = CalculationResult(
    electricity: 0.04,
    filament: 0.29,
    risk: 0,
    labour: 0,
    total: 0.33,
  );

  static const initializedResults = CalculationResult(
    electricity: 0.12,
    filament: 1.35,
    risk: 0.27,
    labour: 0.2,
    total: 1.77,
  );

  static const multiMaterialResults = CalculationResult(
    electricity: 0.04,
    filament: 0.29,
    risk: 0,
    labour: 0,
    total: 0.33,
  );

  static HistoryModel fallbackHistoryModel() {
    return HistoryModel(
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
  }

  static HistoryModel initializedHistoryModel() {
    return HistoryModel(
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
        MaterialUsageInput(
          materialId: 'mat-standard',
          materialName: 'PETG Black',
          costPerKg: 29.99,
          weightGrams: 45,
        ).toMap(),
      ],
      timeHours: '01:30',
    );
  }

  static HistoryModel multiMaterialHistoryModel() {
    return HistoryModel(
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
        MaterialUsageInput(
          materialId: 'mat-a',
          materialName: 'PLA Black',
          costPerKg: 20,
          weightGrams: 9,
        ).toMap(),
        MaterialUsageInput(
          materialId: 'mat-b',
          materialName: 'PLA White',
          costPerKg: 27.5,
          weightGrams: 4,
        ).toMap(),
      ],
      timeHours: '01:00',
    );
  }

  static Map<String, dynamic> legacySingleMaterialRaw() {
    return {
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
    };
  }

  static Map<String, dynamic> legacyEmptyBreakdownRaw() {
    return {
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
    };
  }
}

void expectStoredHistoryCsv(StoredHistoryEvidence evidence) {
  expect(evidence.csvLines, [
    historyCsvHeader,
    expectedHistoryCsvRow(evidence.entry.model),
  ]);
}

class FakeCalculatorPreferencesRepository
    implements CalculatorPreferencesRepository {
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

Future<CalculationSnapshot> runCalculation({
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
        FakeCalculatorPreferencesRepository(),
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
    return CalculationSnapshot(state: state, results: state.results);
  } finally {
    container.dispose();
    await db.close();
  }
}

Future<HistoryModel> captureSavedModel(
  WidgetTester tester, {
  required CalculatorState state,
  required CalculationResult results,
  required String name,
  required GeneralSettingsModel settings,
  Map<String, PrinterModel> printers = const {},
  Map<String, MaterialModel> materials = const {},
}) async {
  final helpers = FakeCalculatorHelpers();

  final db = await tester
      .pumpApp(SaveForm(data: results, showSave: ValueNotifier<bool>(true)), [
        calculatorProvider.overrideWith(
          () => FakeCalculatorNotifier(initialState: state),
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

Future<StoredHistoryEvidence> storeAndReadHistory(HistoryModel model) async {
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
    final raw = (await historyStore.record(key).get(db))!;
    final entry = (await historyRepository.getAllHistory()).single;
    final csv = await csvUtils.queryHistory(ExportRange.all);
    return StoredHistoryEvidence(
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

Future<StoredHistoryEvidence> storeLegacyRecord(
  Map<String, dynamic> raw,
) async {
  final db = await databaseFactoryMemory.openDatabase(
    'legacy_${DateTime.now().microsecondsSinceEpoch}.db',
  );
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );

  try {
    await historyStore.add(db, raw);
    final historyRepository = container.read(historyRepositoryProvider);
    final csvUtils = container.read(csvUtilsProvider);
    final entry = (await historyRepository.getAllHistory()).single;
    final csv = await csvUtils.queryHistory(ExportRange.all);
    return StoredHistoryEvidence(
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

Future<bool> tryLoadLegacy({
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
        FakeCalculatorPreferencesRepository(),
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

Future<Map<String, String>> pumpCalculatorResultsView(
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

Future<Map<String, String>> pumpHistoryItemView(
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

String expectedHistoryCsvRow(HistoryModel item) {
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
      '"${item.totalCost}",'
      '"${item.pricingMarkupPercent ?? ''}",'
      '"${item.pricingMarkupAmount ?? ''}",'
      '"${item.pricingSetupFee ?? ''}",'
      '"${item.pricingRoundingMode ?? ''}",'
      '"${item.pricingSubtotalBeforeRounding ?? ''}",'
      '"${item.pricingRoundingAdjustment ?? ''}",'
      '"${item.finalPrice ?? ''}"';
}

String _textByKey(WidgetTester tester, Key key) {
  return tester.widget<Text>(find.byKey(key)).data!;
}
