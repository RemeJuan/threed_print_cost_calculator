import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';

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
      await tester.pumpApp(
        const CalculatorPage(),
        [
          calculatorProvider.overrideWith((_) => mockCalculatorProvider),
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
