import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_section.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
    SharedPreferences.setMockInitialValues({});
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        calculatorProvider.overrideWith(() => mockCalculatorProvider),
      ]);
      addTearDown(() => db.close());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets(
      'add material -> select -> row appears and remove updates total',
      (tester) async {
        final db = await tester.pumpApp(
          const Scaffold(body: MaterialsSection()),
        );
        addTearDown(() => db.close());

        final materialsStore = stringMapStoreFactory.store(
          DBName.materials.name,
        );
        await materialsStore.record('mat_1').put(db, {
          'name': 'PLA Black',
          'color': 'Black',
          'cost': '20',
          'weight': '1000',
        });

        await tester.pumpAndSettle();

        // Tap the add icon in the header to open the material picker
        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PLA Black').first);
        await tester.pumpAndSettle();

        expect(find.text('PLA Black'), findsWidgets);

        final weightField = find.byType(TextFormField).last;
        await tester.enterText(weightField, '120');
        await tester.pumpAndSettle();

        expect(find.text('Total material weight: 120g'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
        await tester.pumpAndSettle();

        expect(find.text('Total material weight: 0g'), findsOneWidget);
      },
      skip: true,
    );
  });
}
