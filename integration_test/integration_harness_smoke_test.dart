import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches the app as a free user via the shared harness', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.free();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);

    expect(
      find.byKey(const ValueKey<String>('nav.calculator.button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('nav.settings.button')),
      findsOneWidget,
    );
    expect(find.text('History'), findsNothing);
  });

  testWidgets('launches the app as a premium user via the shared harness', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);

    expect(find.text('History'), findsOneWidget);
  });

  testWidgets(
    'seed helpers provide deterministic settings, printers, and materials',
    (tester) async {
      final harness = await IntegrationTestHarness.premium(
        seed: (harness) async {
          await harness.seedPrinters([IntegrationFixtures.printerA]);
          await harness.seedMaterials([IntegrationFixtures.materialPlaBlack]);
          await harness.seedSettings(IntegrationFixtures.settings);
        },
      );
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);
      await _tapByKey(tester, 'nav.settings.button');

      final settings = await harness.container
          .read(settingsRepositoryProvider)
          .getSettings();
      final printers = await harness.container
          .read(printersRepositoryProvider)
          .getPrinters();
      final materials = await harness.container
          .read(materialsRepositoryProvider)
          .getMaterials();

      expect(
        _focusSafeFieldText(tester, 'settings.electricityCost.input'),
        '3.00',
      );
      expect(
        _focusSafeFieldText(tester, 'settings.generalWattage.input'),
        '120',
      );
      expect(settings, IntegrationFixtures.settings);
      expect(printers.single.name, IntegrationFixtures.printerA.name);
      expect(materials.single.name, IntegrationFixtures.materialPlaBlack.name);
    },
  );
}

Future<void> _tapByKey(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey<String>(key));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

String _focusSafeFieldText(WidgetTester tester, String key) {
  final widget = tester.widget<FocusSafeTextField>(
    find.byKey(ValueKey<String>(key)),
  );
  return widget.controller.text;
}
