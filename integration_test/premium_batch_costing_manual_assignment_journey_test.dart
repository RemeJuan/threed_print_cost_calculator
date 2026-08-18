import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'fixtures/integration_fixtures.dart';
import 'helpers/integration_test_harness.dart';
import 'helpers/integration_test_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'premium user adds a manual batch item, assigns it, and saves the summary',
    (tester) async {
      const itemName = 'Batch Benchy';
      const quoteName = 'Batch Quote';
      const printerName = 'Batch Printer';
      const printerBedSize = '250x250x250';
      const printerWattage = 120;
      const materialName = 'Batch PLA';
      const materialColor = 'Black';
      const materialWeight = 1000;
      const materialCost = 20.00;

      final harness = await IntegrationTestHarness.premium(
        seed: (harness) async {
          await harness.seedPrinters([
            IntegrationFixtures.buildPrinter(
              id: 'printer-1',
              name: printerName,
              bedSize: printerBedSize,
              wattage: '$printerWattage',
            ),
          ]);
          await harness.seedMaterials([
            IntegrationFixtures.buildMaterial(
              id: 'material-1',
              name: materialName,
              color: materialColor,
              weight: '$materialWeight',
              cost: materialCost.toStringAsFixed(2),
            ),
          ]);
        },
      );
      addTearDown(harness.dispose);

      await tester.launchHarnessApp(harness);
      await tester.tapByKey('calculator.batch_costing.open.button');
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      )!;

      await tester.tap(find.text(l10n.batchCostingReviewAddManualItemButton));
      await tester.pumpAndSettle();
      await tester.enterTextByKey('batch-costing-item-name', itemName);
      await tester.enterTextByKey('batch-costing-item-quantity', '1');
      await tester.enterTextByKey('batch-costing-item-weight', '50');
      await tester.enterTextByKey('batch-costing-item-duration-hours', '1');
      await tester.enterTextByKey('batch-costing-item-duration-minutes', '30');
      await tester.tapByKey('batch-costing-item-editor-save');
      await tester.pumpAndSettle();

      await tester.tapByKey('batch-costing-continue-button');
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(l10n.batchCostingPrinterAssignmentBatchWideMode),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(printerName).last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.batchCostingPrinterAssignmentNextButton).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(l10n.batchCostingMaterialAssignmentBatchWideMode),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(materialName).last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(l10n.batchCostingMaterialAssignmentNextButton).last,
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.text(l10n.batchCostingPrinterAssignmentNextButton).last,
      );
      await tester.pumpAndSettle();

      final quoteSaveButton = find
          .byKey(const ValueKey<String>('batch-costing-summary-save-button'))
          .last;
      await tester.ensureVisible(quoteSaveButton);
      await tester.pumpAndSettle();
      await tester.tap(quoteSaveButton);
      await tester.pumpAndSettle();
      await tester.enterTextByKey('batch-costing-quote-name-input', quoteName);
      final dialogSaveButton = find
          .byKey(const ValueKey<String>('batch-costing-quote-save-button'))
          .last;
      await tester.tap(dialogSaveButton);
      await tester.pumpAndSettle();

      final historyRepository = harness.container.read(
        historyRepositoryProvider,
      );
      expect(await historyRepository.countHistory(), 1);
    },
  );
}
