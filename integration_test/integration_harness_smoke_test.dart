import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

// Local-only harness smoke test.
// Keeps the shared integration bootstrap honest, but is not part of the CI E2E gate.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches the app as a free user via the shared harness', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.free();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(
      find.byKey(const ValueKey<String>('nav.calculator.button')),
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
  });

  testWidgets('launches the app as a premium user via the shared harness', (
    tester,
  ) async {
    final harness = await IntegrationTestHarness.premium();
    addTearDown(harness.dispose);

    await tester.launchHarnessApp(harness);
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(
      find.byKey(const ValueKey<String>('nav.history.button')),
      findsOneWidget,
    );
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
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await tester.tapByKey('nav.settings.button');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      await tester.scrollUntilKeyVisible('settings.electricityCost.input');

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
        tester.focusSafeFieldText('settings.electricityCost.input'),
        '3.00',
      );
      expect(tester.focusSafeFieldText('settings.generalWattage.input'), '120');
      expect(
        find.byKey(const ValueKey<String>('settings.general.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.interface.section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('settings.workCost.section')),
        findsOneWidget,
      );
      await tester.tapByKey('nav.history.button');
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      expect(
        find.byKey(const ValueKey<String>('history.export.button')),
        findsOneWidget,
      );
      expect(settings, IntegrationFixtures.settings);
      expect(printers.single.name, IntegrationFixtures.printerA.name);
      expect(materials.single.name, IntegrationFixtures.materialPlaBlack.name);
    },
  );
}
