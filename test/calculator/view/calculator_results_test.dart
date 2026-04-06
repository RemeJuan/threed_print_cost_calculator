import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_results.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

void main() {
  setUp(() async {
    // await setupTest();
  });

  group('CalculatorPage', () {
    testWidgets('renders CalculatorView', (tester) async {
      final db = await tester.pumpApp(
        const CalculatorResults(
          results: CalculationResult(
            electricity: 0.0,
            filament: 0.0,
            risk: 0.0,
            labour: 0.0,
            total: 0.0,
          ),
        ),
        [isPremiumProvider.overrideWithValue(true)],
      );
      addTearDown(() => db.close());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorResults), findsOneWidget);
    });
  });
}
