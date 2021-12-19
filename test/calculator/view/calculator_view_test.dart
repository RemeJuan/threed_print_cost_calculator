import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';

import '../../helpers/helpers.dart';

void main() {
  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      await tester.pumpApp(const CalculatorPage());
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
