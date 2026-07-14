import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> expectNavShell(WidgetTester tester) async {
    expect(
      find.byKey(const ValueKey<String>('nav.calculator.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nav.materials.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nav.history.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nav.settings.button')),
      findsOneWidget,
    );
  }

  testWidgets(
    'free shell gates history and keeps clean premium override state',
    (tester) async {
      final harness = await IntegrationTestHarness.free();
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);
      await expectNavShell(tester);

      await tester.tapByKey('nav.history.button');
      expect(
        find.byKey(const ValueKey<String>('history.teaser.state')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('history.export.button')),
        findsNothing,
      );

      await tester.tapByKey('nav.settings.button');
      expect(
        find.byKey(const ValueKey<String>('settings.general.section')),
        findsOneWidget,
      );

      await tester.tapByKey('nav.calculator.button');
      expect(
        find.byKey(const ValueKey<String>('calculator.reset.button')),
        findsOneWidget,
      );

      expect(
        harness.container
            .read(premiumLocalStoreProvider)
            .readSync(testPremiumOverrideEnabledOnPreferenceKey),
        isNull,
      );
    },
  );

  testWidgets(
    'premium shell shows history export and keeps base surfaces reachable',
    (tester) async {
      final harness = await IntegrationTestHarness.premium();
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);
      await expectNavShell(tester);

      await tester.tapByKey('nav.history.button');
      expect(
        find.byKey(const ValueKey<String>('history.teaser.state')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey<String>('history.export.button')),
        findsOneWidget,
      );

      await tester.tapByKey('nav.settings.button');
      expect(
        find.byKey(const ValueKey<String>('settings.general.section')),
        findsOneWidget,
      );

      await tester.tapByKey('nav.calculator.button');
      expect(
        find.byKey(const ValueKey<String>('calculator.reset.button')),
        findsOneWidget,
      );
    },
  );
}
