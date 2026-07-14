import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_contact_email.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('whitespace support id uses no-id body', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));

    final email = buildHelpSupportContactEmail(
      l10n,
      supportId: '   ',
      appVersion: null,
    );
    expect(email.body, l10n.helpSupportContactEmailBodyNoSupportId('—'));
  });

  testWidgets('null version falls back to em dash', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));

    final email = buildHelpSupportContactEmail(
      l10n,
      supportId: 'id-42',
      appVersion: null,
    );
    expect(email.body, contains('App version: —'));
  });

  testWidgets('empty version stays empty', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('en'));

    final email = buildHelpSupportContactEmail(
      l10n,
      supportId: '   ',
      appVersion: '',
    );
    expect(email.body, l10n.helpSupportContactEmailBodyNoSupportId(''));
  });
}
