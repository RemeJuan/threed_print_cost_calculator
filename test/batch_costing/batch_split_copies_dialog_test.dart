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

  testWidgets('shows all printers in dialog', (tester) async {
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
              printers: [
                printer('p1', 'Printer 1'),
                printer('p2', 'Printer 2'),
              ],
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Printer 1'), findsOneWidget);
    expect(find.text('Printer 2'), findsOneWidget);
    expect(find.text('Quantity: 5'), findsOneWidget);
  });

  testWidgets('validates total equals item quantity on save', (tester) async {
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
              printers: [
                printer('p1', 'Printer 1'),
                printer('p2', 'Printer 2'),
              ],
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Total must equal 5'), findsOneWidget);
  });

  testWidgets('saves valid allocation', (tester) async {
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
                printers: [
                  printer('p1', 'Printer 1'),
                  printer('p2', 'Printer 2'),
                ],
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, '3');
    await tester.enterText(textFields.last, '2');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.length, 2);
  });

  testWidgets('auto-balances default printer when editing another printer', (
    tester,
  ) async {
    List<BatchAssignmentAllocation>? result;

    await tester.pumpApp(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            result = await showDialog<List<BatchAssignmentAllocation>>(
              context: context,
              builder: (_) => BatchSplitCopiesDialog(
                itemName: 'Test Item',
                itemQuantity: 13,
                allocations: const [
                  BatchAssignmentAllocation(targetId: 'p1', quantity: 13),
                ],
                printers: [
                  printer('p1', 'Printer 1'),
                  printer('p2', 'Printer 2'),
                  printer('p3', 'Printer 3'),
                ],
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3));

    expect(
      (tester.widget<TextField>(textFields.first).controller!.value.text),
      '13',
    );
    expect(
      (tester.widget<TextField>(textFields.at(1)).controller!.value.text),
      '0',
    );
    expect(
      (tester.widget<TextField>(textFields.last).controller!.value.text),
      '0',
    );

    // Set Printer 2 to 5 copies — Printer 1 should auto-decrement to 8
    await tester.enterText(textFields.at(1), '5');
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(textFields.first).controller!.value.text),
      '8',
    );
    expect(find.text('Total must equal 13'), findsNothing);

    // Set Printer 3 to 3 copies — Printer 1 should drop to 5
    await tester.enterText(textFields.last, '3');
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(textFields.first).controller!.value.text),
      '5',
    );
    expect(find.text('Total must equal 13'), findsNothing);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.length, 3);
  });

  testWidgets('clamps at zero when others exceed quantity', (tester) async {
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
                  BatchAssignmentAllocation(targetId: 'p1', quantity: 5),
                ],
                printers: [
                  printer('p1', 'Printer 1'),
                  printer('p2', 'Printer 2'),
                ],
              ),
            );
          },
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);

    // Set Printer 2 to 8 copies (exceeds quantity 5) — Printer 1 should clamp to 0
    await tester.enterText(textFields.last, '8');
    await tester.pumpAndSettle();

    expect(
      (tester.widget<TextField>(textFields.first).controller!.value.text),
      '0',
    );
    // Total = 8 + 0 = 8 ≠ 5, should show error
    expect(find.text('Total must equal 5'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('manual default printer edit still validates total', (
    tester,
  ) async {
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
              printers: [
                printer('p1', 'Printer 1'),
                printer('p2', 'Printer 2'),
              ],
            ),
          ),
          child: const Text('Open'),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);

    // Edit default printer (index 0) directly — no auto-balance, just validate
    await tester.enterText(textFields.first, '10');
    await tester.pumpAndSettle();

    // Total = 10 + 0 = 10 ≠ 5
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
                printers: [
                  printer('p1', 'Printer 1'),
                  printer('p2', 'Printer 2'),
                ],
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
