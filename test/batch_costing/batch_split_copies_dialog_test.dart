import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_split_copies_dialog.dart';
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

  testWidgets('search add edit remove validate cancel', (tester) async {
    List<BatchAssignmentAllocation>? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<List<BatchAssignmentAllocation>>(
              context: context,
              builder: (_) => BatchSplitCopiesDialog(
                itemName: 'Test Item',
                itemQuantity: 5,
                allocations: const [
                  BatchAssignmentAllocation(targetId: 'p1', quantity: 3),
                ],
                printers: [printer('p1', 'Printer 1'), printer('p2', 'Printer 2')],
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Printer 1'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('allocation_picker_search')), 'Printer 2');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Printer 2'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('allocation_picker_qty_1')), '2');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, hasLength(2));
  });

  testWidgets('invalid total blocks save', (tester) async {
    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showDialog<List<BatchAssignmentAllocation>>(
            context: context,
            builder: (_) => BatchSplitCopiesDialog(
              itemName: 'Test Item',
              itemQuantity: 5,
              allocations: const [
                BatchAssignmentAllocation(targetId: 'p1', quantity: 3),
              ],
              printers: [printer('p1', 'Printer 1')],
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('allocation_picker_qty_0')), '4');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Total must equal 5'), findsOneWidget);
  });

  testWidgets('cancel returns null', (tester) async {
    List<BatchAssignmentAllocation>? result;
    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<List<BatchAssignmentAllocation>>(
              context: context,
              builder: (_) => BatchSplitCopiesDialog(
                itemName: 'Test Item',
                itemQuantity: 5,
                allocations: const [
                  BatchAssignmentAllocation(targetId: 'p1', quantity: 3),
                ],
                printers: [printer('p1', 'Printer 1')],
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });
}
