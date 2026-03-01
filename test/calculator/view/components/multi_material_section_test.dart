import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/multi_material_section.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../../../helpers/helpers.dart';
import '../../../helpers/mocks.dart';

// A notifier stub that starts with a pre-configured state.
class _StubNotifier extends CalculatorProvider {
  final CalculatorState initialState;

  _StubNotifier(this.initialState);

  @override
  CalculatorState build() => initialState;

  @override
  void init() {} // no-op in tests

  @override
  void submit() {} // no-op in tests

  @override
  void submitDebounced({Duration delay = const Duration(milliseconds: 250)}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
  });

  group('MultiMaterialSection', () {
    testWidgets('shows "Add material" button', (tester) async {
      final stub = _StubNotifier(CalculatorState());
      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(find.text('Add material'), findsOneWidget);
    });

    testWidgets('renders a row for each material usage', (tester) async {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 35,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];
      final stub = _StubNotifier(
        CalculatorState(materialUsages: usages),
      );

      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(find.text('PLA Black'), findsOneWidget);
      expect(find.text('PLA White'), findsOneWidget);
    });

    testWidgets('shows total weight row when more than one material', (
      tester,
    ) async {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 100,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 50,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];
      final stub = _StubNotifier(
        CalculatorState(materialUsages: usages),
      );

      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(find.text('Total material weight'), findsOneWidget);
    });

    testWidgets('does not show total weight row for single material', (
      tester,
    ) async {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
      ];
      final stub = _StubNotifier(
        CalculatorState(materialUsages: usages),
      );

      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(find.text('Total material weight'), findsNothing);
    });

    testWidgets('remove button hidden when only one material', (tester) async {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 120,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
      ];
      final stub = _StubNotifier(
        CalculatorState(materialUsages: usages),
      );

      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      // remove_circle_outline icon should not be present when only 1 material
      expect(find.byIcon(Icons.remove_circle_outline), findsNothing);
    });

    testWidgets('remove buttons shown when multiple materials', (tester) async {
      final usages = [
        const MaterialUsage(
          materialId: 'mat1',
          materialName: 'PLA Black',
          weightGrams: 100,
          spoolWeight: 1000,
          spoolCost: 20.0,
        ),
        const MaterialUsage(
          materialId: 'mat2',
          materialName: 'PLA White',
          weightGrams: 50,
          spoolWeight: 500,
          spoolCost: 15.0,
        ),
      ];
      final stub = _StubNotifier(
        CalculatorState(materialUsages: usages),
      );

      final db = await tester.pumpApp(
        const MultiMaterialSection(),
        [
          calculatorProvider.overrideWith(() => stub),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.remove_circle_outline),
        findsNWidgets(2),
      );
    });
  });

  group('HistoryModel — materialUsages backward compatibility', () {
    test('fromMap with no materialUsages returns empty list', () {
      final map = {
        'name': 'Old Print',
        'totalCost': 10.0,
        'riskCost': 1.0,
        'filamentCost': 5.0,
        'electricityCost': 2.0,
        'labourCost': 2.0,
        'date': '2024-01-01T00:00:00.000Z',
        'printer': 'Bambu X1',
        'material': 'PLA Black',
        'weight': 120.0,
        'timeHours': '02:30',
        // No 'materialUsages' key — simulates old record
      };

      final model = HistoryModel.fromMap(map);
      expect(model.materialUsages, isEmpty);
      expect(model.material, equals('PLA Black'));
      expect(model.weight, equals(120.0));
    });

    test('fromMap with materialUsages parses correctly', () {
      final map = {
        'name': 'New Print',
        'totalCost': 15.0,
        'riskCost': 1.5,
        'filamentCost': 8.0,
        'electricityCost': 3.0,
        'labourCost': 2.5,
        'date': '2024-06-01T00:00:00.000Z',
        'printer': 'Bambu X1',
        'material': 'PLA Black',
        'weight': 155,
        'timeHours': '03:00',
        'materialUsages': [
          {
            'materialId': 'mat1',
            'materialName': 'PLA Black',
            'weightGrams': 120,
            'spoolWeight': 1000,
            'spoolCost': 20.0,
            'filamentCost': 2.40,
          },
          {
            'materialId': 'mat2',
            'materialName': 'PLA White',
            'weightGrams': 35,
            'spoolWeight': 500,
            'spoolCost': 15.0,
            'filamentCost': 1.05,
          },
        ],
      };

      final model = HistoryModel.fromMap(map);
      expect(model.materialUsages.length, equals(2));
      expect(model.materialUsages[0].materialName, equals('PLA Black'));
      expect(model.materialUsages[0].weightGrams, equals(120));
      expect(model.materialUsages[1].materialName, equals('PLA White'));
      expect(model.materialUsages[1].weightGrams, equals(35));
    });

    test('materialsLabel uses materialUsages when available', () {
      final map = {
        'name': 'Multi',
        'totalCost': 10.0,
        'riskCost': 1.0,
        'filamentCost': 5.0,
        'electricityCost': 2.0,
        'labourCost': 2.0,
        'date': '2024-06-01T00:00:00.000Z',
        'printer': 'Bambu',
        'material': 'PLA Black',
        'weight': 155,
        'timeHours': '02:00',
        'materialUsages': [
          {
            'materialId': 'mat1',
            'materialName': 'PLA Black',
            'weightGrams': 120,
            'spoolWeight': 1000,
            'spoolCost': 20.0,
            'filamentCost': 2.40,
          },
          {
            'materialId': 'mat2',
            'materialName': 'PLA White',
            'weightGrams': 35,
            'spoolWeight': 500,
            'spoolCost': 15.0,
            'filamentCost': 1.05,
          },
        ],
      };

      final model = HistoryModel.fromMap(map);
      expect(
        model.materialsLabel,
        equals('PLA Black: 120g, PLA White: 35g'),
      );
    });

    test('materialsLabel falls back to legacy material field when usages empty', () {
      final map = {
        'name': 'Old',
        'totalCost': 10.0,
        'riskCost': 1.0,
        'filamentCost': 5.0,
        'electricityCost': 2.0,
        'labourCost': 2.0,
        'date': '2024-01-01T00:00:00.000Z',
        'printer': 'Bambu',
        'material': 'PETG Red',
        'weight': 80.0,
        'timeHours': '01:30',
      };

      final model = HistoryModel.fromMap(map);
      expect(model.materialsLabel, equals('PETG Red'));
    });

    test('toMap round-trips materialUsages correctly', () {
      const usage = MaterialUsage(
        materialId: 'mat1',
        materialName: 'PLA Black',
        weightGrams: 120,
        spoolWeight: 1000,
        spoolCost: 20.0,
        filamentCost: 2.40,
      );
      final model = HistoryModel(
        name: 'Test',
        totalCost: 10.0,
        riskCost: 1.0,
        filamentCost: 2.40,
        electricityCost: 3.0,
        labourCost: 2.0,
        date: DateTime(2024),
        printer: 'Bambu',
        material: 'PLA Black',
        weight: 120,
        timeHours: '02:00',
        materialUsages: [usage],
      );

      final map = model.toMap();
      final restored = HistoryModel.fromMap(map);

      expect(restored.materialUsages.length, equals(1));
      expect(restored.materialUsages.first.materialName, equals('PLA Black'));
      expect(restored.materialUsages.first.weightGrams, equals(120));
      expect(restored.materialUsages.first.filamentCost, equals(2.40));
    });
  });
}
