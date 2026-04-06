import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
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

  Future<Database> pumpAppPage(
    WidgetTester tester,
    FakePurchasesGateway gateway,
    FakeCalculatorNotifier calculatorNotifier,
  ) async {
    sharedPreferences = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const AppPage(), [
      calculatorProvider.overrideWith(() => calculatorNotifier),
      settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      purchasesGatewayProvider.overrideWithValue(gateway),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value(const <MaterialModel>[]),
      ),
    ]);
    addTearDown(db.close);
    addTearDown(gateway.dispose);
    return db;
  }

  testWidgets('shows free nav without history', (tester) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(find.text(S.current.historyNavLabel), findsNothing);
    expect(find.text(S.current.calculatorNavLabel), findsOneWidget);
    expect(find.text(S.current.settingsNavLabel), findsOneWidget);
  });

  testWidgets('premium changes update nav items from gateway updates', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();
    expect(find.text(S.current.historyNavLabel), findsNothing);

    gateway.emit(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.current.historyNavLabel), findsOneWidget);

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-2'),
    );
    await tester.pumpAndSettle();
    expect(find.text(S.current.historyNavLabel), findsNothing);
  });

  testWidgets('selected index clamps when history tab disappears', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('nav.settings.button')));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    expect(find.text(S.current.historyNavLabel), findsNothing);
  });

  testWidgets('run count increments on resolved non-empty user ids only', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: true),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(sharedPreferences.getInt('run_count'), 0);

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'user-1'),
    );
    await tester.pumpAndSettle();
    expect(sharedPreferences.getInt('run_count'), 1);

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'user-1'),
    );
    await tester.pumpAndSettle();
    expect(sharedPreferences.getInt('run_count'), 1);
  });

  testWidgets('startup calculator init and submit are wired', (tester) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(calculatorNotifier.initCalls, greaterThan(0));
    expect(calculatorNotifier.submitCalls, greaterThan(0));
  });
}
