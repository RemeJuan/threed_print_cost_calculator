import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  late FakeAnalytics analytics;

  setUp(() {
    analytics = FakeAnalytics();
    AppAnalytics.service = analytics;
    seedAppPagePrefs(runCount: 0);
  });

  testWidgets('shows free nav with history', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(historyNavFinder(), findsOneWidget);
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).calculatorNavLabel),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).settingsNavLabel),
      findsOneWidget,
    );
  });

  testWidgets('does not show whats new when app page route is not current', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());
    final announcementCompleter = Completer<WhatsNewAnnouncement?>();

    await pumpAppPage(
      tester,
      gateway,
      calculatorNotifier,
      useDefaultAnnouncementOverride: false,
      overrides: [
        currentAnnouncementProvider.overrideWith(
          (ref) => announcementCompleter.future,
        ),
      ],
    );
    await tester.pump();

    final context = tester.element(find.byType(BottomNavigationBar));
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Overlay route')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    announcementCompleter.complete(whatsNewAnnouncement);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Overlay route'), findsOneWidget);
    expect(find.text('Got it'), findsNothing);
    expect(analytics.events.where((e) => e == 'whats_new_shown'), isEmpty);
  });

  testWidgets(
    'does not show whats new if the route changes before the post frame callback',
    (tester) async {
      final calculatorNotifier = FakeCalculatorNotifier();
      final gateway = FakePurchasesGateway(freeUser());
      final announcementCompleter = Completer<WhatsNewAnnouncement?>();

      await pumpAppPage(
        tester,
        gateway,
        calculatorNotifier,
        useDefaultAnnouncementOverride: false,
        overrides: [
          currentAnnouncementProvider.overrideWith(
            (ref) => announcementCompleter.future,
          ),
        ],
      );
      await tester.pump();

      announcementCompleter.complete(whatsNewAnnouncement);
      await tester.pump();

      final context = tester.element(find.byType(BottomNavigationBar));
      unawaited(
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Overlay route')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Overlay route'), findsOneWidget);
      expect(find.text('Got it'), findsNothing);
      expect(analytics.events.where((e) => e == 'whats_new_shown'), isEmpty);
    },
  );

  testWidgets('shows teaser history tab for free users when promos enabled', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(historyNavFinder(), findsOneWidget);
    expect(historyBadgeFinder(), findsNothing);
  });

  testWidgets('free users can hide history promo badge and keep history tab', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final freeGateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, freeGateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(historyNavFinder(), findsOneWidget);
    expect(historyBadgeFinder(), findsNothing);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(historyNavFinder(), findsOneWidget);
    expect(historyBadgeFinder(), findsNothing);
  });

  testWidgets('premium changes update nav items from gateway updates', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);
    expect(historyNavFinder(), findsOneWidget);

    gateway.emit(premiumUser());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(historyNavFinder(), findsOneWidget);

    gateway.emit(freeUser(userId: 'free-2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(historyNavFinder(), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('opening materials tab logs analytics once per open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(
      analytics.events.where((e) => e == 'materials_view_opened'),
      isEmpty,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.materials.button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      analytics.events.where((e) => e == 'materials_view_opened').length,
      1,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.calculator.button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.materials.button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      analytics.events.where((e) => e == 'materials_view_opened').length,
      2,
    );
  });
}
