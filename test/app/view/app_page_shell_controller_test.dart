import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

PageView _pageView(WidgetTester tester) => tester.widget(find.byType(PageView));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  late FakeAnalytics analytics;

  setUp(() {
    analytics = FakeAnalytics();
    AppAnalytics.service = analytics;
    seedAppPagePrefs(runCount: 0);
  });

  testWidgets('pending tab navigation syncs and clears', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    appProviderContainer!
        .read(pendingTabNavigationProvider.notifier)
        .navigate(AppPageTab.materials);
    await tester.pump();
    await settleAppPage(tester);

    expect(appProviderContainer!.read(pendingTabNavigationProvider), isNull);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
    expect(_pageView(tester).controller!.page, 1);
  });

  testWidgets('unavailable pending tab consumes then falls back', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());
    final interfaceSettingsRepository = FakeInterfaceSettingsRepository(
      initialSettings: const InterfaceSettingsModel(showMaterialsTab: false),
    );

    await pumpAppPage(
      tester,
      gateway,
      calculatorNotifier,
      interfaceSettingsRepository: interfaceSettingsRepository,
    );
    await settleAppPage(tester);

    appProviderContainer!
        .read(pendingTabNavigationProvider.notifier)
        .navigate(AppPageTab.materials);
    await tester.pump();
    await tester.pump();

    expect(appProviderContainer!.read(pendingTabNavigationProvider), isNull);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );
    expect(_pageView(tester).controller!.page, 0);
  });

  testWidgets('tap guard ignores intermediate page callbacks', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    final navigation = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    final pageView = tester.widget<PageView>(find.byType(PageView));
    navigation.onTap!(3);
    pageView.onPageChanged!(1);
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      3,
    );

    await tester.pump(const Duration(milliseconds: 600));
    pageView.onPageChanged!(3);
    await tester.pump();
    pageView.controller!.jumpToPage(2);
    await tester.pump();
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );
  });

  testWidgets(
    'history loaded returns to calculator and shows success message',
    (tester) async {
      SharedPreferences.setMockInitialValues({'run_count': 0});
      final calculatorNotifier = FakeCalculatorNotifier();
      final gateway = FakePurchasesGateway(freeUser());

      await pumpAppPage(tester, gateway, calculatorNotifier);
      await settleAppPage(tester);

      await tester.tap(
        find.byKey(const ValueKey<String>('nav.history.button')),
      );
      await settleAppPage(tester);

      final historyPage = tester.widget<HistoryPage>(find.byType(HistoryPage));
      await historyPage.onHistoryLoaded!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        0,
      );
      expect(_pageView(tester).controller!.page, 0);
      expect(find.text(l10n.historyLoadSuccessMessage), findsOneWidget);
    },
  );

  testWidgets('removed history tab falls back to calculator', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());
    final interfaceSettingsRepository = FakeInterfaceSettingsRepository(
      initialSettings: const InterfaceSettingsModel(),
    );

    await pumpAppPage(
      tester,
      gateway,
      calculatorNotifier,
      interfaceSettingsRepository: interfaceSettingsRepository,
    );
    await settleAppPage(tester);

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await settleAppPage(tester);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      2,
    );

    await interfaceSettingsRepository.saveSettings(
      const InterfaceSettingsModel(showHistoryTab: false),
    );
    appProviderContainer!.invalidate(interfaceSettingsFutureProvider);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );
    expect(_pageView(tester).controller!.page, 0);
  });

  testWidgets('removed materials tab falls back to calculator', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());
    final interfaceSettingsRepository = FakeInterfaceSettingsRepository(
      initialSettings: const InterfaceSettingsModel(),
    );

    await pumpAppPage(
      tester,
      gateway,
      calculatorNotifier,
      interfaceSettingsRepository: interfaceSettingsRepository,
    );
    await settleAppPage(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.materials.button')),
    );
    await settleAppPage(tester);
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );

    await interfaceSettingsRepository.saveSettings(
      const InterfaceSettingsModel(showMaterialsTab: false),
    );
    appProviderContainer!.invalidate(interfaceSettingsFutureProvider);
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );
    expect(_pageView(tester).controller!.page, 0);
  });
}
