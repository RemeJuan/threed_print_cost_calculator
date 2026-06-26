import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  setUp(() {
    seedAppPagePrefs(runCount: 0);
  });

  testWidgets('selected index stays stable across entitlement changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
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
      3,
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
      3,
    );
    expect(historyNavFinder(), findsOneWidget);
  });

  testWidgets('swiping between pages updates bottom navigation selection', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump(const Duration(seconds: 10));
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

  testWidgets('history tab remains visible when promos are hidden', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsWidgets,
    );
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
  });

  testWidgets('free history starts in full mode and keeps export gated', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('history.teaser.state')),
      findsNothing,
    );

    gateway.emit(premiumUser());
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
    expect(historyBadgeFinder(), findsNothing);
  });

  testWidgets('re-enabling history promo keeps settings selected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

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
      3,
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(historyNavFinder(), findsOneWidget);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      3,
    );
  });
}
