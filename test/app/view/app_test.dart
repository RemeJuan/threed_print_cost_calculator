// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;
  late SharedPreferences sharedPreferences;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
    SharedPreferences.setMockInitialValues({});
  });

  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      sharedPreferences = await SharedPreferences.getInstance();
      final db = await tester.pumpApp(const App(), [
        calculatorProvider.overrideWith(() => mockCalculatorProvider),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ]);
      addTearDown(() => db.close());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });
  });
}
