import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_list.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(() async {
    await setupTest();
  });

  group('MaterialsList', () {
    testWidgets('renders empty list when no usages', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders single material row', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.text('PLA Black'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders multiple material rows', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
            MaterialUsageInput(
              materialId: 'mat-2',
              materialName: 'PLA White',
              costPerKg: 250,
              weightGrams: 50,
            ),
            MaterialUsageInput(
              materialId: 'mat-3',
              materialName: 'PETG',
              costPerKg: 300,
              weightGrams: 25,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.text('PLA Black'), findsOneWidget);
      expect(find.text('PLA White'), findsOneWidget);
      expect(find.text('PETG'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('calls onPick when material row is tapped', (tester) async {
      int? pickedIndex;

      await tester.pumpApp(
        MaterialsList(
          usages: const [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
          ],
          materialsById: const {},
          onPick: (index) => pickedIndex = index,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      await tester.tap(find.text('PLA Black'));
      await tester.pumpAndSettle();

      expect(pickedIndex, equals(0));
    });

    testWidgets('calls onWeightChanged when weight input changes', (tester) async {
      int? changedIndex;
      int? newWeight;

      await tester.pumpApp(
        MaterialsList(
          usages: const [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
          ],
          materialsById: const {},
          onPick: _emptyCallback,
          onWeightChanged: (index, grams) {
            changedIndex = index;
            newWeight = grams;
          },
          onRemove: _emptyCallback,
        ),
      );

      await tester.enterText(find.byType(TextFormField), '150');
      await tester.pumpAndSettle();

      expect(changedIndex, equals(0));
      expect(newWeight, equals(150));
    });

    testWidgets('displays weight value in text field', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 123,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.text('123'), findsOneWidget);
    });

    testWidgets('displays empty string when weight is zero', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 0,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, equals(''));
    });

    testWidgets('passes material model to MaterialRow', (tester) async {
      final materialsById = {
        'mat-1': MaterialModel(
          id: 'mat-1',
          name: 'PLA Black',
          color: '#000000',
          weight: '1000',
          cost: '200',
        ),
      };

      await tester.pumpApp(
        MaterialsList(
          usages: const [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
          ],
          materialsById: materialsById,
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.text('PLA Black'), findsOneWidget);
    });

    testWidgets('applies scrollbar when list is long', (tester) async {
      final usages = List.generate(
        10,
        (i) => MaterialUsageInput(
          materialId: 'mat-$i',
          materialName: 'Material $i',
          costPerKg: 200,
          weightGrams: 100,
        ),
      );

      await tester.pumpApp(
        MaterialsList(
          usages: usages,
          materialsById: const {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.byType(Scrollbar), findsOneWidget);
    });

    testWidgets('constrains height for more than 4 items', (tester) async {
      final usages = List.generate(
        5,
        (i) => MaterialUsageInput(
          materialId: 'mat-$i',
          materialName: 'Material $i',
          costPerKg: 200,
          weightGrams: 100,
        ),
      );

      await tester.pumpApp(
        MaterialsList(
          usages: usages,
          materialsById: const {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      expect(constrainedBox.constraints.maxHeight, isFinite);
    });

    testWidgets('does not constrain height for 4 or fewer items with weight', (tester) async {
      final usages = List.generate(
        4,
        (i) => MaterialUsageInput(
          materialId: 'mat-$i',
          materialName: 'Material $i',
          costPerKg: 200,
          weightGrams: 100,
        ),
      );

      await tester.pumpApp(
        MaterialsList(
          usages: usages,
          materialsById: const {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      expect(constrainedBox.constraints.maxHeight, equals(double.infinity));
    });

    testWidgets('does not constrain height for single item with zero weight', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'Material 1',
              costPerKg: 200,
              weightGrams: 0,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );

      expect(constrainedBox.constraints.maxHeight, equals(double.infinity));
    });

    testWidgets('handles missing material in materialsById', (tester) async {
      await tester.pumpApp(
        const MaterialsList(
          usages: [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
          ],
          materialsById: {},
          onPick: _emptyCallback,
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      expect(find.text('PLA Black'), findsOneWidget);
    });

    testWidgets('calls correct callback for each row', (tester) async {
      final pickedIndices = <int>[];

      await tester.pumpApp(
        MaterialsList(
          usages: const [
            MaterialUsageInput(
              materialId: 'mat-1',
              materialName: 'PLA Black',
              costPerKg: 200,
              weightGrams: 100,
            ),
            MaterialUsageInput(
              materialId: 'mat-2',
              materialName: 'PLA White',
              costPerKg: 250,
              weightGrams: 50,
            ),
          ],
          materialsById: const {},
          onPick: (index) => pickedIndices.add(index),
          onWeightChanged: _emptyWeightCallback,
          onRemove: _emptyCallback,
        ),
      );

      await tester.tap(find.text('PLA Black'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PLA White'));
      await tester.pumpAndSettle();

      expect(pickedIndices, equals([0, 1]));
    });
  });
}

void _emptyCallback(int index) {}

void _emptyWeightCallback(int index, int grams) {}