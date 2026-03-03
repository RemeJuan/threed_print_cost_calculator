import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_row.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

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

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: material,
              onPick: () {},
              onWeightChanged: (w) => updatedWeight = w,
              onRemove: () {},
            ),
          ),
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

    testWidgets('displays hex color indicator when valid hex color provided', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      final material = MaterialModel(
        id: 'm1',
        name: 'PLA',
        cost: '20',
        color: '#FF0000',
        weight: '1000',
        archived: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: material,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final colorContainer = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 14,
      );
      expect(colorContainer, findsOneWidget);
    });

    testWidgets('displays color text when invalid hex color provided', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      final material = MaterialModel(
        id: 'm1',
        name: 'PLA',
        cost: '20',
        color: 'Red',
        weight: '1000',
        archived: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: material,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('- (Red)'), findsOneWidget);
    });

    testWidgets('shows Unassigned when materialName is Unassigned', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'none',
        materialName: 'Unassigned',
        costPerKg: 0,
        weightGrams: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Select'), findsOneWidget);
    });

    testWidgets('shows empty string in weight field when weight is zero', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.initialValue, equals(''));
    });

    testWidgets('calls onPick when material name is tapped', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      bool pickCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () => pickCalled = true,
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('PLA'));
      await tester.pumpAndSettle();

      expect(pickCalled, isTrue);
    });

    testWidgets('does not show delete button for Unassigned material', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'none',
        materialName: 'Unassigned',
        costPerKg: 0,
        weightGrams: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Slidable), findsNothing);
    });

    testWidgets('shows delete button for valid material', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Slidable), findsOneWidget);
    });

    testWidgets('does not show delete button for empty material id', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: '',
        materialName: 'Unassigned',
        costPerKg: 0,
        weightGrams: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Slidable), findsNothing);
    });

    testWidgets('handles invalid weight input with zero', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      int? updatedWeight;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: null,
              onPick: () {},
              onWeightChanged: (w) => updatedWeight = w,
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final weightField = find.byType(TextFormField);
      await tester.enterText(weightField, 'invalid');
      await tester.pumpAndSettle();

      expect(updatedWeight, equals(0));
    });

    testWidgets('handles hex color with alpha channel', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      final material = MaterialModel(
        id: 'm1',
        name: 'PLA',
        cost: '20',
        color: '#FF0000FF',
        weight: '1000',
        archived: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: material,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final colorContainer = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 14,
      );
      expect(colorContainer, findsOneWidget);
    });

    testWidgets('handles hex color without hash prefix', (
      WidgetTester tester,
    ) async {
      const usage = MaterialUsageInput(
        materialId: 'm1',
        materialName: 'PLA',
        costPerKg: 20,
        weightGrams: 50,
      );

      final material = MaterialModel(
        id: 'm1',
        name: 'PLA',
        cost: '20',
        color: 'FF0000',
        weight: '1000',
        archived: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MaterialRow(
              index: 0,
              usage: usage,
              material: material,
              onPick: () {},
              onWeightChanged: (_) {},
              onRemove: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final colorContainer = find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxWidth == 14,
      );
      expect(colorContainer, findsOneWidget);
    });
  });
}