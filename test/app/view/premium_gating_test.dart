import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/purchases_gateway.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

class FakePurchasesGateway implements PurchasesGateway {
  FakePurchasesGateway(this._currentState);

  PremiumState _currentState;
  final StreamController<PremiumState> _controller =
      StreamController<PremiumState>.broadcast();

  @override
  Future<PremiumState> fetchPremiumState() async => _currentState;

  @override
  Stream<PremiumState> watchPremiumState() => _controller.stream;

  void emit(PremiumState nextState) {
    _currentState = nextState;
    _controller.add(nextState);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

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

  testWidgets('free state keeps premium history gate hidden', (tester) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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

  testWidgets('premium state shows premium history gate', (tester) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
    sharedPreferences = await SharedPreferences.getInstance();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free'),
    );

    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => mockCalculatorProvider),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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
