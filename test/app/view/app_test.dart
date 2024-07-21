// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
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

  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpApp(
        const App(),
        [
          calculatorProvider.overrideWith((_) => mockCalculatorProvider),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
