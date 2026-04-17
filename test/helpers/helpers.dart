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
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';

Future<void> setupTest() async {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({});

  // Replace analytics with a no-op implementation to avoid initializing
  // Firebase during tests. Tests that want to assert analytics calls can
  // replace this with a mock.
  AppAnalytics.service = _NoopAnalytics();
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
    List<NavigatorObserver> observers = const [],
  ]) async {
    // Provide a default in-memory database override first. Tests can still
    // override this by passing their own override which will appear later.
    final name = 'test_helpers_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final sharedPreferences = await SharedPreferences.getInstance();
    final effectiveOverrides = <Override>[
      databaseProvider.overrideWithValue(db),
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
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

    return db;
  }
}
