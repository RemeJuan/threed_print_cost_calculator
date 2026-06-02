import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/printer_select.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    List<Override> additionalOverrides = const [],
  }) async {
    SharedPreferences.setMockInitialValues({'run_count': 0, ...prefs});
    await SharedPreferences.getInstance();
    await SharedPreferences.getInstance();

    await tester.pumpApp(const CalculatorPage(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      purchasesGatewayProvider.overrideWithValue(gateway),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value(const <MaterialModel>[]),
      ),
      ...additionalOverrides,
    ]);
  }

  testWidgets('free users see printer picker when printers exist', (
    tester,
  ) async {
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
      additionalOverrides: [
        printersStreamProvider.overrideWith(
          (ref) => Stream.value([
            PrinterModel(
              id: 'p1',
              name: 'P1',
              bedSize: '220x220',
              wattage: '120',
              archived: false,
            ),
          ]),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byType(PrinterSelect), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('calculator.save.open.button')),
      findsOneWidget,
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

  testWidgets('reset action confirms before calling notifier reset', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    final paywallPresenter = FakePaywallPresenter();

    await pumpPage(tester, gateway, calculatorNotifier, paywallPresenter);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('calculator.reset.button')),
    );
    await tester.pumpAndSettle();

    expect(calculatorNotifier.resetCalls, 0);

    final dialogContext = tester.element(find.byType(AlertDialog));
    final l10n = AppLocalizations.of(dialogContext)!;
    await tester.tap(
      find.widgetWithText(ElevatedButton, l10n.resetButtonLabel),
    );
    await tester.pumpAndSettle();

    expect(calculatorNotifier.resetCalls, 1);
  });
}
