import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      await tester.pumpApp(
        const CalculatorPage(),
        [
          calculatorProvider.overrideWith((_) => mockCalculatorProvider),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
