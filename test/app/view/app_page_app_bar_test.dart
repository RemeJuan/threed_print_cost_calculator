import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';
import 'app_page_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(bootstrapAppPageTests);

  setUp(() {
    seedAppPagePrefs(runCount: 0);
  });

  testWidgets('premium app bar icons match the source of truth', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(premiumUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey<String>('nav.materials.button')),
    );
    await settleAppPage(tester);

    expect(find.byIcon(Icons.file_upload_outlined), findsOneWidget);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
    expect(find.byIcon(Icons.file_upload_outlined), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('nav.settings.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.shopping_cart), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
    expect(find.byIcon(Icons.file_upload_outlined), findsNothing);
  });

  testWidgets('free app bar icons match the source of truth', (tester) async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    final calculatorNotifier = FakeCalculatorNotifier();
    final gateway = FakePurchasesGateway(freeUser());

    await pumpAppPage(tester, gateway, calculatorNotifier);
    await settleAppPage(tester);

    expect(find.byIcon(Icons.help_outline), findsOneWidget);
    expect(historyBadgeFinder(), findsNothing);
    expect(find.byIcon(Icons.upload_file_outlined), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('nav.history.button')));
    await settleAppPage(tester);

    expect(find.byIcon(Icons.upload_file_outlined), findsNothing);
  });
}
