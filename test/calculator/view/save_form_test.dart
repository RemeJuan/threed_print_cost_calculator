import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/save_form.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(() async {
    await setupTest();
  });

  group('SaveForm', () {
    testWidgets('renders text field and buttons', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('save button is disabled when name is empty', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      final saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );

      expect(saveButton.onPressed, isNull);
    });

    testWidgets('save button is enabled when name is not empty', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      await tester.enterText(find.byType(TextField), 'Test Print');
      await tester.pumpAndSettle();

      final saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );

      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('cancel button sets showSave to false', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      expect(showSave.value, isTrue);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(showSave.value, isFalse);
    });

    testWidgets('text field shows hint text', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, isNotEmpty);
    });

    testWidgets('text field updates name value on change', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      await tester.enterText(find.byType(TextField), 'My Print');
      await tester.pumpAndSettle();

      expect(find.text('My Print'), findsOneWidget);
    });

    testWidgets('has correct layout with margin', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      final container = tester.widget<Container>(
        find.byType(Container),
      );

      expect(container.margin, equals(const EdgeInsets.only(bottom: 16)));
    });

    testWidgets('contains row layout', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('text field is expanded', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      expect(
        find.ancestor(
          of: find.byType(TextField),
          matching: find.byType(Expanded),
        ),
        findsOneWidget,
      );
    });

    testWidgets('handles empty calculation results', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 0.0,
        filament: 0.0,
        risk: 0.0,
        labour: 0.0,
        total: 0.0,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      await tester.enterText(find.byType(TextField), 'Empty Print');
      await tester.pumpAndSettle();

      final saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );

      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('widget rebuilds when showSave changes', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      expect(find.byType(SaveForm), findsOneWidget);

      showSave.value = false;
      await tester.pumpAndSettle();

      expect(find.byType(SaveForm), findsOneWidget);
    });

    testWidgets('handles long print names', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      const longName = 'This is a very long print name that should still work';
      await tester.enterText(find.byType(TextField), longName);
      await tester.pumpAndSettle();

      expect(find.text(longName), findsOneWidget);
    });

    testWidgets('handles special characters in name', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      const specialName = 'Print #1 (v2.0) - Test!';
      await tester.enterText(find.byType(TextField), specialName);
      await tester.pumpAndSettle();

      expect(find.text(specialName), findsOneWidget);
    });

    testWidgets('re-enables save button when text is re-entered after clearing', (tester) async {
      final showSave = ValueNotifier<bool>(true);
      const data = CalculationResult(
        electricity: 1.0,
        filament: 2.0,
        risk: 0.5,
        labour: 15.0,
        total: 18.5,
      );

      final mockSharedPreferences = MockSharedPreferences();

      await tester.pumpApp(
        SaveForm(data: data, showSave: showSave),
        [sharedPreferencesProvider.overrideWithValue(mockSharedPreferences)],
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pumpAndSettle();

      var saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );
      expect(saveButton.onPressed, isNotNull);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );
      expect(saveButton.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'Test Again');
      await tester.pumpAndSettle();

      saveButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.save),
      );
      expect(saveButton.onPressed, isNotNull);
    });
  });
}