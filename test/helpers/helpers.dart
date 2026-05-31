// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:threed_print_cost_calculator/core/analytics/analytics_service.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

void safeBotToastCleanAll() {
  try {
    BotToast.cleanAll();
  } catch (_) {
    // BotToast can already be torn down in some test paths.
  }
}

Future<void> setupTest() async {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({});

  // Replace analytics with a no-op implementation to avoid initializing
  // Firebase during tests. Tests that want to assert analytics calls can
  // replace this with a mock.
  AppAnalytics.service = _NoopAnalytics();
  AppAnalytics.resetGcodeImportTrackingForTests();
}

class _NoopAnalytics implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? params}) async {
    // intentionally no-op
    return Future.value();
  }
}

extension PumpApp on WidgetTester {
  Future<Database> pumpApp(
    Widget widget, [
    List<Override> overrides = const [],
    PremiumLocalStore? premiumLocalStore,
    List<NavigatorObserver> observers = const [],
  ]) async {
    final name = 'test_helpers_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final sharedPreferences = await SharedPreferences.getInstance();
    final effectivePremiumLocalStore =
        premiumLocalStore ??
        InMemoryPremiumLocalStore({
          for (final key in sharedPreferences.getKeys())
            key: sharedPreferences.get(key)?.toString() ?? '',
        });
    final effectiveOverrides = <Override>[
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      premiumLocalStoreProvider.overrideWithValue(effectivePremiumLocalStore),
      ...overrides,
    ];

    await pumpWidget(
      ProviderScope(
        overrides: effectiveOverrides,
        child: MaterialApp(
          builder: BotToastInit(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
          navigatorObservers: [BotToastNavigatorObserver(), ...observers],
        ),
      ),
    );

    addTearDown(safeBotToastCleanAll);

    return db;
  }

  Future<ProviderContainer> pumpAppWithContainer(
    Widget widget, {
    List<Override> overrides = const [],
    PremiumLocalStore? premiumLocalStore,
    List<NavigatorObserver> observers = const [],
  }) async {
    final name = 'test_helpers_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final sharedPreferences = await SharedPreferences.getInstance();
    final effectivePremiumLocalStore =
        premiumLocalStore ??
        InMemoryPremiumLocalStore({
          for (final key in sharedPreferences.getKeys())
            key: sharedPreferences.get(key)?.toString() ?? '',
        });
    final effectiveOverrides = <Override>[
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      premiumLocalStoreProvider.overrideWithValue(effectivePremiumLocalStore),
      ...overrides,
    ];

    final container = ProviderContainer(overrides: effectiveOverrides);
    addTearDown(container.dispose);

    await pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          builder: BotToastInit(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: widget),
          navigatorObservers: [BotToastNavigatorObserver(), ...observers],
        ),
      ),
    );
    await pumpAndSettle();

    addTearDown(safeBotToastCleanAll);

    return container;
  }
}
