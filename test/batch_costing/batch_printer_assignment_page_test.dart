import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
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
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
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
    SharedPreferences.setMockInitialValues({
      batchCostingEnabledPreferenceKey: true,
    });
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

  testWidgets('disabled feature shows nothing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      isPremiumProvider.overrideWithValue(false),
    ]);
    expect(find.text('Printer assignment'), findsNothing);
  });
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);
  final List<BatchCostingItem> _items;
  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}
