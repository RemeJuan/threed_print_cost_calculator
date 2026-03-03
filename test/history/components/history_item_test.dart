import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/components/history_item.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

import '../../helpers/helpers.dart';

void main() {
  setUpAll(() async {
    await setupTest();
  });

  group('HistoryItem', () {
    testWidgets('displays print name', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('Test Print'), findsOneWidget);
    });

    testWidgets('displays date formatted correctly', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('15 Jan 2024'), findsOneWidget);
    });

    testWidgets('displays electricity cost', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.25,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('1.25'), findsOneWidget);
    });

    testWidgets('displays filament cost', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.75,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('2.75'), findsOneWidget);
    });

    testWidgets('displays labour cost', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('15.00'), findsOneWidget);
    });

    testWidgets('displays risk cost', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('0.50'), findsOneWidget);
    });

    testWidgets('displays total cost', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('18.50'), findsOneWidget);
    });

    testWidgets('displays printer name', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Ender 3',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('Ender 3'), findsOneWidget);
    });

    testWidgets('displays material name', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PETG Blue',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('PETG Blue'), findsOneWidget);
    });

    testWidgets('displays weight in kg', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 1500,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('1.50 kg'), findsOneWidget);
    });

    testWidgets('displays time in hours and minutes format', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '05:45',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('5h 45m'), findsOneWidget);
    });

    testWidgets('displays materials count badge for multiple materials', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [
          {'materialId': 'mat1', 'materialName': 'PLA Black', 'weightGrams': '50'},
          {'materialId': 'mat2', 'materialName': 'PLA White', 'weightGrams': '50'},
        ],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('2'), findsWidgets);
    });

    testWidgets('does not display materials count badge for single material', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [
          {'materialId': 'mat1', 'materialName': 'PLA Black', 'weightGrams': '100'},
        ],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      final badgeContainers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (widget) => widget is Container &&
                      widget.decoration != null &&
                      widget.decoration is BoxDecoration,
        ),
      );

      // Should not have a materials count badge
      final hasBadge = badgeContainers.any((container) {
        final decoration = container.decoration as BoxDecoration?;
        return decoration?.color == Colors.white12;
      });

      expect(hasBadge, isFalse);
    });

    testWidgets('displays material breakdown for multiple materials', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black +1',
        weight: 150,
        materialUsages: const [
          {'materialId': 'mat1', 'materialName': 'PLA Black', 'weightGrams': '100'},
          {'materialId': 'mat2', 'materialName': 'PLA White', 'weightGrams': '50'},
        ],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('PLA Black | 100g'), findsOneWidget);
      expect(find.textContaining('PLA White | 50g'), findsOneWidget);
    });

    testWidgets('is slidable for export action', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.byType(Slidable), findsOneWidget);
    });

    testWidgets('handles zero costs', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 0.0,
        filamentCost: 0.0,
        totalCost: 0.0,
        riskCost: 0.0,
        labourCost: 0.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('0.00'), findsWidgets);
    });

    testWidgets('handles empty time string gracefully', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.byType(HistoryItem), findsOneWidget);
    });

    testWidgets('handles malformed time string', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: 'invalid',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.textContaining('invalid'), findsOneWidget);
    });

    testWidgets('displays divider between cost rows and total', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('handles empty material usages list', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.byType(HistoryItem), findsOneWidget);
    });

    testWidgets('handles very large numbers', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 999.99,
        filamentCost: 999.99,
        totalCost: 3999.96,
        riskCost: 999.99,
        labourCost: 999.99,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 9999,
        materialUsages: const [],
        timeHours: '99:99',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'key1', data: data),
      );

      expect(find.text('999.99'), findsWidgets);
      expect(find.text('3999.96'), findsOneWidget);
    });

    testWidgets('uses unique key for slidable', (tester) async {
      final data = HistoryModel(
        name: 'Test Print',
        electricityCost: 1.0,
        filamentCost: 2.0,
        totalCost: 18.5,
        riskCost: 0.5,
        labourCost: 15.0,
        date: DateTime(2024, 1, 15),
        printer: 'Printer 1',
        material: 'PLA Black',
        weight: 100,
        materialUsages: const [],
        timeHours: '02:30',
      );

      await tester.pumpApp(
        HistoryItem(dbKey: 'unique_key_123', data: data),
      );

      final slidable = tester.widget<Slidable>(find.byType(Slidable));
      expect(slidable.key, equals(const ValueKey('unique_key_123')));
    });
  });
}