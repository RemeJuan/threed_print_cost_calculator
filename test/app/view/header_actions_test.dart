import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users see the cart action and open subscriptions', (
    tester,
  ) async {
    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pump();

    expect(find.byType(Subscriptions), findsOneWidget);
  });

  testWidgets('premium users do not see the cart action', (tester) async {
    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
  });
}
