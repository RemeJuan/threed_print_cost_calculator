import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_summary_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_pricing_scope_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  testWidgets('shows empty state with back action when no items', (
    tester,
  ) async {
    await tester.pumpApp(const BatchSummaryPage(), [
      batchCostingProvider.overrideWith(() => _EmptyBatchCostingNotifier()),
      isPremiumProvider.overrideWithValue(true),
    ]);

    expect(find.text('No batch summary yet'), findsOneWidget);
    expect(find.text('Back to pricing scope'), findsOneWidget);
  });

  testWidgets('shows calculated totals and item breakdown', (tester) async {
    await tester.pumpApp(const BatchSummaryPage(), [
      batchCostingProvider.overrideWith(() => _SummaryBatchCostingNotifier()),
      isPremiumProvider.overrideWithValue(true),
    ]);

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchSummaryPage)),
    )!;

    expect(find.text('1'), findsWidgets);
    expect(find.text('2'), findsWidgets);
    expect(find.text('20.00 g'), findsOneWidget);
    expect(find.text('02:00'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('27.00'), 200);
    await tester.pumpAndSettle();

    expect(find.text('27.00'), findsOneWidget);
    expect(find.text(l10n.batchCostingSummarySaveButton), findsOneWidget);

    await tester.tap(find.text('Benchy'));
    await tester.pumpAndSettle();

    expect(
      find.text(l10n.batchCostingSummaryItemBaseCostLabel),
      findsOneWidget,
    );
    expect(
      find.text(l10n.batchCostingSummaryItemAdjustmentLabel),
      findsOneWidget,
    );
    expect(find.text(l10n.batchCostingSummaryItemTotalLabel), findsOneWidget);

    expect(find.text('Save'), findsNothing);
    expect(find.text('Export'), findsNothing);
    expect(find.text('Share'), findsNothing);
    expect(find.text('History'), findsNothing);
  });

  testWidgets('free-user summary includes material cost after pricing skip', (
    tester,
  ) async {
    await tester.pumpApp(const BatchSummaryPage(), [
      batchCostingProvider.overrideWith(
        () => _FreeSummaryBatchCostingNotifier(),
      ),
      isPremiumProvider.overrideWithValue(false),
      materialsStreamProvider.overrideWith(
        (ref) => Stream.value(const [
          MaterialModel(
            id: 'mat-1',
            name: 'PLA',
            cost: '20',
            color: 'Black',
            weight: '1000',
            archived: false,
          ),
        ]),
      ),
      settingsStreamProvider.overrideWith(
        (ref) => Stream.value(GeneralSettingsModel.initial()),
      ),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('0.60'), findsOneWidget);
  });

  testWidgets('start new batch clears gcode stack and returns home', (
    tester,
  ) async {
    const openBatchLabel = 'Open batch';

    await tester.pumpApp(const _BatchFlowHomeHarness(), [
      batchCostingProvider.overrideWith(() => _SummaryBatchCostingNotifier()),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.tap(find.text(openBatchLabel));
    await tester.pumpAndSettle();

    unawaited(
      Navigator.of(tester.element(find.byType(BatchCostingPage))).push(
        MaterialPageRoute<void>(builder: (_) => const BatchGCodeImportPage()),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(
      Navigator.of(tester.element(find.byType(BatchGCodeImportPage))).push(
        MaterialPageRoute<void>(
          builder: (_) => const BatchPrinterAssignmentPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(
      Navigator.of(
        tester.element(find.byType(BatchPrinterAssignmentPage)),
      ).push(
        MaterialPageRoute<void>(
          builder: (_) => const BatchMaterialAssignmentPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(
      Navigator.of(
        tester.element(find.byType(BatchMaterialAssignmentPage)),
      ).push(
        MaterialPageRoute<void>(builder: (_) => const BatchPricingScopePage()),
      ),
    );
    await tester.pumpAndSettle();

    unawaited(
      Navigator.of(
        tester.element(find.byType(BatchPricingScopePage)),
      ).push(MaterialPageRoute<void>(builder: (_) => const BatchSummaryPage())),
    );
    await tester.pumpAndSettle();

    expect(
      find.byType(BatchGCodeImportPage, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byType(BatchPrinterAssignmentPage, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byType(BatchMaterialAssignmentPage, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byType(BatchPricingScopePage, skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byType(BatchSummaryPage, skipOffstage: false), findsOneWidget);

    await tester.scrollUntilVisible(find.byType(AppSecondaryButton), 200);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppSecondaryButton).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AppPrimaryButton).last);
    await tester.pumpAndSettle();

    expect(
      find.byType(BatchGCodeImportPage, skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byType(BatchPrinterAssignmentPage, skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byType(BatchMaterialAssignmentPage, skipOffstage: false),
      findsNothing,
    );
    expect(
      find.byType(BatchPricingScopePage, skipOffstage: false),
      findsNothing,
    );
    expect(find.byType(BatchSummaryPage, skipOffstage: false), findsNothing);
    expect(find.byType(BatchCostingPage), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(openBatchLabel), findsOneWidget);
    expect(find.byType(BatchCostingPage), findsNothing);
    expect(find.byType(BatchSummaryPage), findsNothing);
  });
}

class _BatchFlowHomeHarness extends StatelessWidget {
  const _BatchFlowHomeHarness();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()),
          );
        },
        child: const Text('Open batch'),
      ),
    );
  }
}

class _EmptyBatchCostingNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() => BatchCostingState();
}

class _SummaryBatchCostingNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() {
    return BatchCostingState(
      items: [
        BatchCostingItem.manual(
          id: 'item-1',
          displayName: 'Benchy',
          quantity: 2,
          printWeightG: 10,
          printDuration: const Duration(hours: 1),
        ),
      ],
      pricing: const BatchPricingState(
        labourRate: BatchPricingFieldState(
          value: '10',
          scope: BatchPricingScope.item,
        ),
        additionalCostAmount: BatchPricingFieldState(
          value: '5',
          scope: BatchPricingScope.batch,
        ),
        markupPercent: BatchPricingFieldState(
          value: '10',
          scope: BatchPricingScope.item,
        ),
      ),
    );
  }
}

class _FreeSummaryBatchCostingNotifier extends BatchCostingNotifier {
  @override
  BatchCostingState build() {
    return BatchCostingState(
      items: [
        BatchCostingItem.manual(
          id: 'item-1',
          displayName: 'Benchy',
          quantity: 3,
          printWeightG: 10,
          printDuration: const Duration(hours: 1),
          materialId: 'mat-1',
        ),
      ],
      batchMaterialId: 'mat-1',
    );
  }
}
