import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/calculator_test_fakes.dart';
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

  testWidgets('shell content follows asymmetric safe areas across resize', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.padding = const FakeViewPadding(top: 40, bottom: 20);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetPadding);

    await pumpAppPage(
      tester,
      FakePurchasesGateway(premiumUser()),
      FakeCalculatorNotifier(),
    );
    await settleAppPage(tester);
    await tester.tap(find.byKey(const ValueKey<String>('nav.settings.button')));
    await settleAppPage(tester);

    tester.view.physicalSize = const Size(466, 678);
    tester.view.padding = const FakeViewPadding(
      left: 32,
      top: 40,
      right: 64,
      bottom: 20,
    );
    await tester.pump();
    await settleAppPage(tester);

    final settingsList = find.byKey(const ValueKey<String>('settings.list'));
    expect(tester.getTopLeft(settingsList).dx, 32);
    expect(tester.getSize(settingsList).width, 466 - 32 - 64);
    expect(
      tester.getTopLeft(find.byIcon(Icons.help_outline)).dx,
      greaterThanOrEqualTo(32),
    );
    expect(
      tester.getTopLeft(find.byIcon(Icons.settings)).dx,
      lessThan(466 - 64),
    );

    tester.view.physicalSize = const Size(669, 951);
    tester.view.padding = const FakeViewPadding(top: 64, bottom: 24);
    await tester.pump();
    await settleAppPage(tester);

    expect(tester.getTopLeft(settingsList).dx, 0);
    expect(tester.getSize(settingsList).width, 669);
  });
}
