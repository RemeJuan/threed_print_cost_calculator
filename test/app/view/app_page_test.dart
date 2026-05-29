import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

class _FakeAnalytics implements AnalyticsService {
  final events = <String>[];

  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    events.add(name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  late _FakeAnalytics analytics;

  const announcement = WhatsNewAnnouncement(
    id: 'wn_42',
    locales: {
      'en': WhatsNewAnnouncementLocale(
        title: 'Title',
        body: 'Body',
        cta: 'Got it',
        unlockProCta: 'Start free trial',
      ),
    },
  );

  setUp(() {
    analytics = _FakeAnalytics();
    AppAnalytics.service = analytics;
    seedAppPagePrefs(runCount: 0);
  });

  testWidgets('shows free nav with history', (tester) async {
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

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
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

    announcementCompleter.complete(announcement);
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

      announcementCompleter.complete(announcement);
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
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nav.history.pro.badge')),
      findsOneWidget,
    );
  });

  testWidgets('free users can hide history promo badge and keep history tab', (
    tester,
  ) async {
    final calculatorNotifier = FakeCalculatorNotifier();
    final freeGateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, freeGateway, calculatorNotifier);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
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

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );

    expect(
      find.byKey(const ValueKey<String>('nav.history.pro.badge')),
      findsNothing,
    );
  });

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
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );

    gateway.emit(
      const PremiumState(isPremium: true, isLoading: false, userId: 'pro-1'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );

    gateway.emit(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-2'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('opening materials tab logs analytics once per open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
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

  testWidgets('premium app bar icons match the source of truth', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': true,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.materials.button')),
    );
    await settleAppPage(tester);

    expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
    expect(find.byIcon(Icons.file_upload_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav.settings.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
    expect(find.byIcon(Icons.file_upload_outlined), findsNothing);
  });

  testWidgets('free app bar icons match the source of truth', (tester) async {
    SharedPreferences.setMockInitialValues({
      'run_count': 0,
      'hideProPromotions': false,
    });
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('nav.history.pro.badge')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
  });

  testWidgets('selected index stays stable across entitlement changes', (
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
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
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
    // Wait for any overlays (rate dialog) to settle
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
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

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

    final container = ProviderScope.containerOf(
      tester.element(find.byType(BottomNavigationBar)),
    );
    await container
        .read(hideProPromotionsProvider.notifier)
        .setHideProPromotions(true);
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
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

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
  });

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
      3,
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

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      3,
    );
  });

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
    final gateway = FakePurchasesGateway(
      const PremiumState(isPremium: false, isLoading: false, userId: 'free-1'),
    );

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await tester.pumpAndSettle();

    expect(calculatorNotifier.initCalls, greaterThan(0));
    expect(calculatorNotifier.submitCalls, greaterThan(0));
  });

  testWidgets('help support page still exposes hidden tools tap target', (
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
    await tester.pumpAndSettle();

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).historyNavLabel),
      findsOneWidget,
    );

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
