import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
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
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);
    expect(find.text(lookupAppLocalizations(const Locale('en')).calculatorNavLabel), findsOneWidget);
    expect(find.text(lookupAppLocalizations(const Locale('en')).settingsNavLabel), findsOneWidget);
  });

  testWidgets('shows teaser history tab for free users when promos enabled', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('nav.history.pro.badge')),
      findsOneWidget,
    );
  });

  testWidgets(
    'free users can hide history promo and premium users always see history',
    (tester) async {
      final calculatorNotifier = FakeCalculatorNotifier();
      final freeGateway = FakePurchasesGateway(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'free-1',
        ),
      );

      await pumpAppPage(tester, freeGateway, calculatorNotifier);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('nav.history.pro.badge')),
        findsOneWidget,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BottomNavigationBar)),
      );
      await container
          .read(hideProPromotionsProvider.notifier)
          .setHideProPromotions(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);

      expect(
        find.byKey(const ValueKey<String>('nav.history.pro.badge')),
        findsNothing,
      );
      expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);
    },
  );

  testWidgets('premium changes update nav items from gateway updates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);

    gateway.emit(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsOneWidget);

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-2'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('selected index clamps when history tab disappears', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

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
    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);
  });

  testWidgets('swiping between pages updates bottom navigation selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );

    final pageView = find.byType(PageView);
    final pageWidth = tester.getSize(pageView).width;

    await tester.fling(pageView, Offset(-pageWidth, 0), 1000);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );

    await tester.fling(pageView, Offset(-pageWidth, 0), 1000);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
  });

  testWidgets(
    'history selection falls back to calculator when tab disappears',
    (tester) async {
      final calculatorNotifier = FakeCalculatorNotifier();
      final gateway = FakePurchasesGateway(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'free-1',
        ),
      );

      await pumpAppPage(tester, gateway, calculatorNotifier);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(
        find.byKey(const ValueKey<String>('nav.history.button')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        1,
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(BottomNavigationBar)),
      );
      await container
          .read(hideProPromotionsProvider.notifier)
          .setHideProPromotions(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsNothing);
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0,
      );
    },
  );

  testWidgets(
    'upgrading from teaser history unlocks full history immediately',
    (tester) async {
      final calculatorNotifier = FakeCalculatorNotifier();
      final gateway = FakePurchasesGateway(
        const PremiumState(
          isPremium: false,
          isLoading: false,
          userId: 'free-1',
        ),
      );

      await pumpAppPage(tester, gateway, calculatorNotifier);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(
        find.byKey(const ValueKey<String>('nav.history.button')),
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      expect(
        find.byKey(const ValueKey<String>('history.teaser.state')),
        findsOneWidget,
      );

      gateway.emit(
        const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.byKey(const ValueKey<String>('history.teaser.state')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('history.export.button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('nav.history.pro.badge')),
        findsNothing,
      );
    },
  );

  testWidgets('re-enabling history promo keeps settings selected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey<String>('nav.settings.button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(BottomNavigationBar)),
    );
    await container
        .read(hideProPromotionsProvider.notifier)
        .setHideProPromotions(false);
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
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
