// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/app/app.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

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
        ],
        child: widget,
      ),
    );
    addTearDown(() => db.close());
    return db;
  }

  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await pumpAppShell(tester, const App());
      await tester.pumpAndSettle();
      expect(find.byType(CalculatorPage), findsOneWidget);
    });

    testWidgets('help button opens the support dialog', (tester) async {
      await pumpAppShell(tester, const App());

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(find.byType(SupportDialog), findsOneWidget);
    });

    testWidgets('support dialog renders directly', (tester) async {
      final db = await tester.pumpApp(const SupportDialog(userID: 'direct'));
      addTearDown(() => db.close());

      await tester.pumpAndSettle();

      expect(find.byType(SupportDialog), findsOneWidget);
      expect(
        find.text(lookupAppLocalizations(const Locale('en')).needHelpTitle),
        findsOneWidget,
      );
    });
  });
}
