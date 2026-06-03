// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

import '../../helpers/helpers.dart';
import '../../helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalculatorNotifier mockCalculatorProvider;

  setUpAll(() async {
    await setupTest();
    PackageInfo.setMockInitialValues(
      appName: 'App',
      packageName: 'pkg',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: 'sig',
    );
  });

  setUp(() {
    mockCalculatorProvider = MockCalculatorNotifier();
    SharedPreferences.setMockInitialValues({});
  });

  Future<Database> pumpAppShell(WidgetTester tester, Widget widget) async {
    final name = 'app_test_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          calculatorProvider.overrideWith(() => mockCalculatorProvider),
          currentAnnouncementProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          builder: BotToastInit(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [BotToastNavigatorObserver()],
          home: widget,
        ),
      ),
    );
    addTearDown(() => db.close());
    addTearDown(safeBotToastCleanAll);
    return db;
  }

  Future<Database> pumpRootApp(
    WidgetTester tester, {
    PremiumLocalStore? premiumLocalStore,
  }) async {
    final name = 'app_root_test_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          premiumLocalStoreProvider.overrideWithValue(
            premiumLocalStore ?? InMemoryPremiumLocalStore(),
          ),
          calculatorProvider.overrideWith(() => mockCalculatorProvider),
          currentAnnouncementProvider.overrideWith((ref) async => null),
        ],
        child: const App(),
      ),
    );
    addTearDown(() => db.close());
    addTearDown(safeBotToastCleanAll);
    return db;
  }

  group('App', () {
    tearDown(() {
      // Clean up any BotToast state between tests
    });

    testWidgets('renders CalculatorPage', (tester) async {
      await pumpAppShell(tester, const AppPage());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets('help button opens the help support page', (tester) async {
      await pumpAppShell(tester, const AppPage());

      await tester.pumpAndSettle();

      final helpButton = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.help_outline),
          matching: find.byType(IconButton),
        ),
      );
      helpButton.onPressed?.call();
      await tester.pumpAndSettle();

      expect(find.byType(HelpSupportPage), findsOneWidget);
    });

    testWidgets('RateMyAppBuilder is always present', (tester) async {
      await pumpRootApp(tester);
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(RateMyAppBuilder), findsOneWidget);
    });

    testWidgets('RateMyAppBuilder present when eligibility threshold met', (
      tester,
    ) async {
      await pumpRootApp(
        tester,
        premiumLocalStore: InMemoryPremiumLocalStore({
          completedCostingCountPreferenceKey: '11',
        }),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(RateMyAppBuilder), findsOneWidget);
    });
  });
}
