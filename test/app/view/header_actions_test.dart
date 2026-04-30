import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users see the cart action and open paywall', (
    tester,
  ) async {
    final paywallPresenter = FakePaywallPresenter();

    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(false),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_cart));
    await tester.pump();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
    expect(paywallPresenter.lastTriggerFeature, 'pro');
    expect(paywallPresenter.lastPurchaseSource, 'header');
    expect(paywallPresenter.lastSource, 'header');
  });

  testWidgets('premium users see the gcode import action', (tester) async {
    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(GCodeImportPage), findsOneWidget);
  });
}
