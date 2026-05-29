import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';

import '../../helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('free users see the gcode import action', (tester) async {
    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(false),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(GCodeImportPage), findsOneWidget);
  });

  testWidgets('premium users see the gcode import action', (tester) async {
    await tester.pumpApp(const HeaderActions(), [
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.upload_file_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(GCodeImportPage), findsOneWidget);
  });
}
