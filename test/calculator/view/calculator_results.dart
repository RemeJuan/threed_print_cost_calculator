import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';

import '../../helpers/helpers.dart';

void main() {
  setUp(() async {
    // await setupTest();
  });

  group(
    'CalculatorPage',
    () {
      testWidgets('renders CalculatorView', (tester) async {
        await tester.pumpApp(
          const CalculatorResults(
            results: <String, String>{
              'electricity': '0.00',
              'filament': '0.00',
              'total': '0.00',
            },
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CalculatorResults), findsOneWidget);
      });
    },
    skip: true,
  );
}
