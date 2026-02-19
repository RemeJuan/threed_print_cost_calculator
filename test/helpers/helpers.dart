// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

Future<void> setupTest() async {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData({});
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, [
    List<Override> overrides = const [],
    List<NavigatorObserver> observers = const [],
  ]) async {
    // Provide a default in-memory database override first. Tests can still
    // override this by passing their own override which will appear later.
    final name = 'test_helpers_${DateTime.now().microsecondsSinceEpoch}.db';
    final db = await databaseFactoryMemory.openDatabase(name);
    final effectiveOverrides = <Override>[
      databaseProvider.overrideWithValue(db),
      ...overrides,
    ];

    return pumpWidget(
      ProviderScope(
        overrides: effectiveOverrides,
        child: MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(body: widget),
          navigatorObservers: [...observers],
        ),
      ),
    );
  }
}
