import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:threed_print_cost_calculator/batch_costing/batch_material_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_printer_assignment_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

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
      quantity: 1,
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

  testWidgets('defaults to batch-wide mode', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value([printer('p1', 'Printer 1')])),
    ]);

    await tester.pumpAndSettle();

    expect(notifier.state.printerAssignmentMode, BatchPrinterAssignmentMode.batchWide);
  });

  testWidgets('batch-wide printer updates state', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value([printer('p1', 'Printer 1')])),
    ]);

    await tester.pumpAndSettle();

    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    dropdown.onChanged?.call('p1');

    expect(notifier.state.batchPrinterId, 'p1');
  });

  testWidgets('per-item mode shows one selector per item', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value([printer('p1', 'Printer 1')])),
    ]);

    await tester.pumpAndSettle();

    final segmentedButton = tester.widget<SegmentedButton<BatchPrinterAssignmentMode>>(
      find.byType(SegmentedButton<BatchPrinterAssignmentMode>),
    );
    segmentedButton.onSelectionChanged?.call({BatchPrinterAssignmentMode.perItem});
    await tester.pumpAndSettle();

    expect(find.text('Benchy'), findsOneWidget);
    expect(find.text('Cube'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
  });

  testWidgets('missing per-item printer blocks continue', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value([printer('p1', 'Printer 1')])),
    ]);

    await tester.pumpAndSettle();

    tester.widget<SegmentedButton<BatchPrinterAssignmentMode>>(
      find.byType(SegmentedButton<BatchPrinterAssignmentMode>),
    ).onSelectionChanged?.call({BatchPrinterAssignmentMode.perItem});
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(BatchPrinterAssignmentPage)))!;
    expect(find.text(l10n.batchCostingPrinterAssignmentRequiredError), findsWidgets);
  });

  testWidgets('complete per-item printers allow continue', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);
    final observer = _TestNavigatorObserver();

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value([printer('p1', 'Printer 1')])),
    ], [observer]);

    await tester.pumpAndSettle();

    tester.widget<SegmentedButton<BatchPrinterAssignmentMode>>(
      find.byType(SegmentedButton<BatchPrinterAssignmentMode>),
    ).onSelectionChanged?.call({BatchPrinterAssignmentMode.perItem});
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Printer 1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<String>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Printer 1').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.byType(BatchMaterialAssignmentPage), findsOneWidget);
    expect(notifier.state.itemPrinterIds['item-1'], 'p1');
    expect(observer.pushedRoute, isNotNull);
  });

  testWidgets('disabled feature shows nothing', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpApp(const BatchPrinterAssignmentPage());

    expect(find.text('Printer assignment'), findsNothing);
  });

  testWidgets('shows no-printers message when none exist', (tester) async {
    SharedPreferences.setMockInitialValues({batchCostingEnabledPreferenceKey: true});
    final notifier = _FakeBatchCostingNotifier(items);

    await tester.pumpApp(const BatchPrinterAssignmentPage(), [
      batchCostingProvider.overrideWith(() => notifier),
      printersStreamProvider.overrideWith((ref) => Stream.value(const <PrinterModel>[])),
    ]);

    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(BatchPrinterAssignmentPage)))!;

    expect(find.text(l10n.batchCostingPrinterAssignmentNoPrintersMessage), findsOneWidget);
    expect(find.byType(Form), findsNothing);
  });
}

class _FakeBatchCostingNotifier extends BatchCostingNotifier {
  _FakeBatchCostingNotifier(this._items);

  final List<BatchCostingItem> _items;

  @override
  BatchCostingState build() => BatchCostingState(items: _items);
}

class _TestNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }
}
