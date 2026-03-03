import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/material_picker.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';

void main() {
  group('MaterialPicker', () {
    testWidgets('shows materials and filters by query, calls onSelected', (
      WidgetTester tester,
    ) async {
      final materials = [
        MaterialModel(
          id: 'm1',
          name: 'PLA White',
          cost: '20',
          color: '#FFFFFF',
          weight: '1000',
          archived: false,
        ),
        MaterialModel(
          id: 'm2',
          name: 'ABS Black',
          cost: '25',
          color: '#000000',
          weight: '1000',
          archived: false,
        ),
      ];

      MaterialModel? selected;

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
            body: MaterialPicker(
              loadMaterials: () async => materials,
              onSelected: (m) => selected = m,
            ),
          ),
        ),
      );

      // Allow FutureBuilder to complete
      await tester.pumpAndSettle();

      // Both materials shown
      expect(find.text('PLA White'), findsOneWidget);
      expect(find.text('ABS Black'), findsOneWidget);

      // Enter search query to filter to PLA
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'pla');
      await tester.pumpAndSettle();

      expect(find.text('PLA White'), findsOneWidget);
      expect(find.text('ABS Black'), findsNothing);

      // Tap the item should call onSelected
      await tester.tap(find.text('PLA White'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.id, equals('m1'));
    });
  });
}
