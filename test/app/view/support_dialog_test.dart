import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import '../../helpers/helpers.dart';

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
}
