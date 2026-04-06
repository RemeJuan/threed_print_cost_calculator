import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPreferences;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({'run_count': 0});
  });

  Future<void> pumpPage(
    WidgetTester tester,
    FakePurchasesGateway gateway,
    FakeCalculatorNotifier calculatorNotifier,
    FakePaywallPresenter paywallPresenter, {
    Map<String, dynamic> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues({'run_count': 0, ...prefs});
    sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpApp(const CalculatorPage(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      purchasesGatewayProvider.overrideWithValue(gateway),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value(const <MaterialModel>[]),
      ),
    ]);
  }

  testWidgets('free users do not see premium controls', (tester) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );
    final paywallPresenter = FakePaywallPresenter();

    await pumpPage(
      tester,
      gateway,
      calculatorNotifier,
      paywallPresenter,
      prefs: {'run_count': 10},
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrinterSelect), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('calculator.save.open.button')),
      findsNothing,
    );
    expect(calculatorNotifier.initCalls, greaterThan(0));
    expect(calculatorNotifier.submitCalls, greaterThan(0));
    expect(paywallPresenter.calls, 0);
  });

  testWidgets('premium users see premium controls', (tester) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    final paywallPresenter = FakePaywallPresenter();

    await pumpPage(tester, gateway, calculatorNotifier, paywallPresenter);
    await tester.pumpAndSettle();

    expect(find.byType(PrinterSelect), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('calculator.save.open.button')),
      findsOneWidget,
    );
    expect(paywallPresenter.calls, 0);
  });

  testWidgets('loading users do not trigger paywall unexpectedly', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: true),
    );
    final paywallPresenter = FakePaywallPresenter();

    await pumpPage(
      tester,
      gateway,
      calculatorNotifier,
      paywallPresenter,
      prefs: {'run_count': 10},
    );
    await tester.pumpAndSettle();

    expect(paywallPresenter.calls, 0);
  });

  testWidgets('premium threshold triggers the paywall presenter', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    final paywallPresenter = FakePaywallPresenter();

    await pumpPage(
      tester,
      gateway,
      calculatorNotifier,
      paywallPresenter,
      prefs: {'run_count': 3},
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
    expect(sharedPreferences.getBool('paywall'), isTrue);
  });
}
