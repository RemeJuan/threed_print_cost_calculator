import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/calculator/view/subscriptions.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('non-premium users see the upgrade prompt', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.byType(Subscriptions), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsNothing,
    );
  });

  testWidgets('premium users can access the import flow', (tester) async {
    await tester.pumpApp(const GCodeImportPage(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(
      find.byKey(const ValueKey<String>('gcode_import.select_file.button')),
      findsOneWidget,
    );
  });
}
