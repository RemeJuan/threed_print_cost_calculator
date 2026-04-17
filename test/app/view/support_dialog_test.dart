import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sembast/sembast.dart' hide Finder;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import '../../helpers/helpers.dart';

Finder _versionTapTarget() {
  return find.byKey(const ValueKey<String>('support.version.tapTarget'));
}

String _todayCode() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
}

Future<void> _openTestDataTools(WidgetTester tester) async {
  await tester.ensureVisible(_versionTapTarget());
  for (var i = 0; i < 5; i++) {
    await tester.tap(_versionTapTarget());
    await tester.pump(const Duration(milliseconds: 200));
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  testWidgets('renders support details and app version', (tester) async {
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());
    await tester.pumpAndSettle();

    expect(
      find.text(lookupAppLocalizations(const Locale('en')).needHelpTitle),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).supportIdLabel),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).clickToCopy),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).privacyPolicyLink),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).termsOfUseLink),
      findsOneWidget,
    );
    expect(
      find.text(lookupAppLocalizations(const Locale('en')).closeButton),
      findsOneWidget,
    );
    expect(
      find.text(
        lookupAppLocalizations(const Locale('en')).versionLabel('1.2.3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('version label opens test data tools after five taps', (
    tester,
  ) async {
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openTestDataTools(tester);

    expect(
      find.byKey(const ValueKey<String>('settings.testData.tools.dialog')),
      findsOneWidget,
    );
  });

  testWidgets('version tap counter resets after timeout', (tester) async {
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await tester.ensureVisible(_versionTapTarget());

    for (var i = 0; i < 4; i++) {
      await tester.tap(_versionTapTarget());
      await tester.pump(const Duration(milliseconds: 200));
    }

    await tester.pump(const Duration(seconds: 4));
    await tester.tap(_versionTapTarget());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.testData.tools.dialog')),
      findsNothing,
    );
  });

  testWidgets('enable premium with correct code seeds data', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openTestDataTools(tester);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.button'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.code'),
      ),
      _todayCode(),
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.submit.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(prefs.getBool('testPremiumOverride'), isTrue);
    expect(
      await stringMapStoreFactory.store(DBName.printers.name).count(db),
      3,
    );
  });

  testWidgets('enable premium with incorrect code shows error', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    final db = await tester.pumpApp(const SupportDialog(userID: 'support-123'));
    addTearDown(() => db.close());

    await tester.pumpAndSettle();
    await _openTestDataTools(tester);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.button'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.code'),
      ),
      'wrong',
    );
    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.testData.enablePremium.submit.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid confirmation code'), findsOneWidget);
    expect(prefs.getBool('testPremiumOverride'), isNull);
  });
}
