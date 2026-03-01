import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
    mockSharedPreferences = MockSharedPreferences();
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        calculatorProvider.overrideWith(() => mockCalculatorProvider),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ]);
      addTearDown(() => db.close());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets('add material -> select -> row appears and remove updates total', (
      tester,
    ) async {
      final db = await tester.pumpApp(const CalculatorPage(), [
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ]);
      addTearDown(() => db.close());

      final materialsStore = stringMapStoreFactory.store(DBName.materials.name);
      await materialsStore.record('mat_1').put(db, {
        'name': 'PLA Black',
        'color': 'Black',
        'cost': '20',
        'weight': '1000',
      });
      await materialsStore.record('mat_2').put(db, {
        'name': 'PLA White',
        'color': 'White',
        'cost': '25',
        'weight': '1000',
      });

      await tester.pumpAndSettle();

      await tester.tap(find.text('Add material'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PLA Black').first);
      await tester.pumpAndSettle();

      expect(find.text('PLA Black'), findsOneWidget);

      final weightField = find.byType(TextFormField).last;
      await tester.enterText(weightField, '120');
      await tester.pumpAndSettle();

      expect(find.text('Total material weight: 120g'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.remove_circle_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Total material weight: 0g'), findsOneWidget);
    });
  });
}
