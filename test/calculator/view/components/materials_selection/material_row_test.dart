import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_row.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('MaterialRow', () {
    testWidgets('shows material name and calls weight callback', (
      WidgetTester tester,
    ) async {
      final usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      final material = MaterialModel(
        id: 'm1',
        name: 'PLA',
        cost: '20',
        color: '#FFFFFF',
        weight: '1000',
        archived: false,
      );

      int? updatedWeight;

      await setupTest();

      await tester.pumpApp(
        MaterialRow(
          index: 0,
          usage: usage,
          material: material,
          onPick: () {},
          onWeightChanged: (w) => updatedWeight = w,
          onRemove: () {},
        ),
      );

      await tester.pumpAndSettle();

      // The weight field should show initial value
      expect(find.text('50'), findsOneWidget);

      // Change weight
      final weightField = find.byType(TextFormField);
      expect(weightField, findsOneWidget);
      await tester.enterText(weightField, '120');
      await tester.pumpAndSettle();

      expect(updatedWeight, equals(120));
    });
  });
}
