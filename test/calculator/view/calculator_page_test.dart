import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';

import '../../helpers/helpers.dart';

void main() {
  setUp(() async {
    await setupTest();
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      await tester.pumpApp(const CalculatorPage());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
