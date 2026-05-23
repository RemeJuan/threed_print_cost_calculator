import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/material_allocation_row.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

import '../helpers/helpers.dart';

void main() {
  setUpAll(setupTest);

  PrinterModel printer(String id, String name) => PrinterModel(
    id: id,
    name: name,
    bedSize: '220x220',
    wattage: '120',
    archived: false,
  );

  final items = [
    BatchCostingItem.manual(
      id: 'item-1',
      displayName: 'Benchy',
      quantity: 3,
      printWeightG: 15,
      printDuration: const Duration(minutes: 30),
    ),
    BatchCostingItem.manual(
      id: 'item-2',
      displayName: 'Cube',
      quantity: 1,
      printWeightG: 20,
      printDuration: const Duration(minutes: 20),
    ),
  ];

  testWidgets('batch-wide printer updates state', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([printer('p1', 'Printer 1')]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Printer 1'));
    await tester.pumpAndSettle();

    expect(notifier.state.batchPrinterId, 'p1');
  });

  testWidgets('per-item mode uses reusable picker', (tester) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([printer('p1', 'Printer 1')]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPrinterAssignmentPage)),
    )!;
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<BatchPrinterAssignmentMode>),
        matching: find.text(l10n.batchCostingPrinterAssignmentPerItemMode),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.batchCostingAssignmentSplitCopiesButton),
      findsNWidgets(2),
    );
    await tester.tap(
      find.text(l10n.batchCostingAssignmentSplitCopiesButton).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Printer 1'), findsOneWidget);
  });

  testWidgets('per-item cards hide placeholder and show selected rows', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([printer('p1', 'Printer 1')]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(BatchPrinterAssignmentPage)),
    )!;
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<BatchPrinterAssignmentMode>),
        matching: find.text(l10n.batchCostingPrinterAssignmentPerItemMode),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNothing);
    expect(find.text('×1'), findsNothing);

    notifier.setItemPrinterId('item-1', 'p1');
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNWidgets(1));
    expect(find.text('Printer 1'), findsOneWidget);
    expect(find.text('×3'), findsOneWidget);
  });

  testWidgets('split printer cards show multiple removable rows', (
    tester,
  ) async {
    final notifier = _FakeBatchCostingNotifier(items);
    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith(
        (ref) => Stream.value([
          printer('p1', 'Printer 1'),
          printer('p2', 'Printer 2'),
        ]),
      ),
      isPremiumProvider.overrideWithValue(true),
    ]);
    await tester.pumpAndSettle();

    notifier.setPrinterAssignmentMode(BatchPrinterAssignmentMode.perItem);
    notifier.setItemPrinterAllocations('item-1', [
      const BatchAssignmentAllocation(targetId: 'p1', quantity: 1),
      const BatchAssignmentAllocation(targetId: 'p2', quantity: 2),
    ]);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialAllocationRow), findsNWidgets(2));
    expect(find.text('Printer 1'), findsOneWidget);
    expect(find.text('Printer 2'), findsOneWidget);
    expect(find.text('×1'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(2));
  });
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);
  final List<BatchCostingItem> _items;
  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
