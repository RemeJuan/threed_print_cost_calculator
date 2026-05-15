import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('hidden when feature flag disabled', (tester) async {
    final db = await tester.pumpApp(const BatchCostingPage());
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(find.text(l10n.batchCostingAppBarTitle), findsNothing);
    expect(find.text(l10n.batchCostingIntro), findsNothing);
  });

  testWidgets('renders screen 0 shell when enabled', (tester) async {
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });

    final db = await tester.pumpApp(const BatchCostingPage());
    addTearDown(() => db.close());

    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(find.text(l10n.batchCostingAppBarTitle), findsOneWidget);
    expect(find.text(l10n.batchCostingIntro), findsOneWidget);
    expect(find.text(l10n.batchCostingImportGcodeBatchButton), findsOneWidget);
    expect(find.text(l10n.batchCostingManualBatchButton), findsOneWidget);
  });
}
