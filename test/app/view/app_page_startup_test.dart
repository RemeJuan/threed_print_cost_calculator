import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  testWidgets('run count increments on resolved non-empty user ids only', (
    tester,
  ) async {
    final premiumLocalStore = InMemoryPremiumLocalStore({
      runCountPreferenceKey: '0',
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: true),
    );

    await pumpAppPage(
      tester,
      gateway,
      calculatorNotifier,
      premiumLocalStore: premiumLocalStore,
    );
    await tester.pumpAndSettle();

    expect(premiumLocalStore.readSync(runCountPreferenceKey), '0');

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'user-1'),
    );
    await tester.pumpAndSettle();
    expect(premiumLocalStore.readSync(runCountPreferenceKey), '1');

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'user-1'),
    );
    await tester.pumpAndSettle();
    expect(premiumLocalStore.readSync(runCountPreferenceKey), '1');
  });

  testWidgets('startup calculator init and submit are wired', (tester) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(calculatorNotifier.initCalls, greaterThan(0));
    expect(calculatorNotifier.submitCalls, greaterThan(0));
  });

  testWidgets('help support page still exposes hidden tools tap target', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(historyNavFinder(), findsOneWidget);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('helpSupport.page')),
      findsOneWidget,
    );

    final versionTapTarget = find.byKey(
      const ValueKey<String>('support.version.tapTarget'),
    );
    await tester.ensureVisible(versionTapTarget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(versionTapTarget);
      await tester.pump(const Duration(milliseconds: 200));
    }
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.testData.tools.dialog')),
      findsOneWidget,
    );
  });
}
