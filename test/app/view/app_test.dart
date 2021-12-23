// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/locator.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabase mockDatabase;

  setUp(() {
    setupTest();

    mockDatabase = MockDatabase();
    sl.registerSingletonAsync<Database>(() async => mockDatabase);
  });

  group(
    'App',
    () {
      testWidgets('renders CounterPage', (tester) async {
        await tester.pumpApp(const App());
        await tester.pumpAndSettle();
        expect(find.byType(CalculatorPage), findsOneWidget);
      });
    },
    skip: true,
  );
}
