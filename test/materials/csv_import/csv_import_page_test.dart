import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  group('CsvImportPage', () {
    testWidgets('shows intro state with upload button', (tester) async {
      final db = await tester.pumpApp(const CsvImportPage());
      await tester.pumpAndSettle();
      addTearDown(db.close);

      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(find.text(l10n.csvImportTitle), findsOneWidget);
      expect(find.text(l10n.csvImportIntro), findsOneWidget);
      expect(find.text(l10n.csvSelectFileButton), findsOneWidget);
      expect(find.text(l10n.csvTemplateButton), findsOneWidget);
    });
  });
}
