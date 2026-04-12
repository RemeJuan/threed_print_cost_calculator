import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_row.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../../../helpers/helpers.dart';

class _MaterialRowHarness extends StatefulWidget {
  const _MaterialRowHarness({required this.onWeightChanged});

  final ValueChanged<int> onWeightChanged;

  @override
  State<_MaterialRowHarness> createState() => _MaterialRowHarnessState();
}

class _MaterialRowHarnessState extends State<_MaterialRowHarness> {
  MaterialUsageInput usage = MaterialUsageInput(
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
    autoDeductEnabled: true,
    originalWeight: 1000,
    remainingWeight: 875,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialRow(
      index: 0,
      usage: usage,
      material: material,
      onPick: () {},
      onWeightChanged: (w) {
        setState(() {
          usage = usage.copyWith(weightGrams: w);
        });
        widget.onWeightChanged(w);
      },
      onRemove: () {},
    );
  }
}

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
        autoDeductEnabled: true,
        originalWeight: 1000,
        remainingWeight: 875,
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
      expect(find.text('Remaining: 875g'), findsOneWidget);
      expect(find.byType(FocusSafeTextField), findsOneWidget);

      // Change weight
      final weightField = find.byType(TextFormField);
      expect(weightField, findsOneWidget);
      await tester.enterText(weightField, '120');
      await tester.pumpAndSettle();

      expect(updatedWeight, equals(120));
    });

    testWidgets('keeps focus while parent rebuilds on weight changes', (
      WidgetTester tester,
    ) async {
      int? updatedWeight;

      await setupTest();
      await tester.pumpApp(
        _MaterialRowHarness(onWeightChanged: (w) => updatedWeight = w),
      );
      await tester.pumpAndSettle();

      final weightField = find.byType(TextFormField);
      await tester.tap(weightField);
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isTrue);

      await tester.enterText(weightField, '1');
      await tester.pump();
      expect(updatedWeight, equals(1));
      expect(tester.testTextInput.hasAnyClients, isTrue);

      await tester.enterText(weightField, '12');
      await tester.pump();
      expect(updatedWeight, equals(12));
      expect(tester.testTextInput.hasAnyClients, isTrue);
    });
  });
}
