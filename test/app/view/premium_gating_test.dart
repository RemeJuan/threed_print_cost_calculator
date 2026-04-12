import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../../test_support/fake_purchases_gateway.dart';
import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('free state keeps premium history gate hidden', (tester) async {
    SharedPreferences.setMockInitialValues({'hideProPromotions': true});
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      purchasesGatewayProvider.overrideWithValue(
        FakePurchasesGateway(
          const PremiumState(
            isPremium: false,
            isLoading: false,
            userId: 'free',
          ),
        ),
      ),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    expect(find.text(S.current.historyNavLabel), findsNothing);
  });

  testWidgets('free state shows teaser history gate when promos enabled', (
    tester,
  ) async {
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      purchasesGatewayProvider.overrideWithValue(
        FakePurchasesGateway(
          const PremiumState(
            isPremium: false,
            isLoading: false,
            userId: 'free',
          ),
        ),
      ),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    expect(find.text(S.current.historyNavLabel), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('nav.history.pro.badge')),
      findsOneWidget,
    );
  });

  testWidgets('premium state shows premium history gate', (tester) async {
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      purchasesGatewayProvider.overrideWithValue(
        FakePurchasesGateway(
          const PremiumState(isPremium: true, isLoading: false, userId: 'pro'),
        ),
      ),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    expect(find.text(S.current.historyNavLabel), findsOneWidget);
  });

  testWidgets('history gate appears when gateway emits premium upgrade', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free'),
    );

    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      purchasesGatewayProvider.overrideWithValue(gateway),
    ]);
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    expect(find.text(S.current.historyNavLabel), findsNothing);

    gateway.emit(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro'),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.current.historyNavLabel), findsOneWidget);
  });
}
