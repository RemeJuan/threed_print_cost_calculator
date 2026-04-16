import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/printers/printers.dart';
import '../settings_test_fakes.dart';

import '../../helpers/helpers.dart';

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

PrinterModel _printer() {
  return const PrinterModel(
    id: 'printer-1',
    name: 'Prusa MK4',
    bedSize: '250x210x220',
    wattage: '350',
    archived: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('renders printer rows from stream state', (tester) async {
    final repo = FakePrintersRepository(
      watchResponses: [
        <PrinterModel>[_printer()],
      ],
    );
    final db = await tester.pumpApp(const Printers(), [
      printersRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('settings.printers.item.0.name')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('settings.printers.item.0.summary')),
      findsOneWidget,
    );
    expect(find.text('Prusa MK4'), findsOneWidget);
    expect(
      find.text('250x210x220 (350${lookupAppLocalizations(const Locale('en')).wattsSuffix})'),
      findsOneWidget,
    );
  });

  testWidgets('retries after a stream error', (tester) async {
    final repo = FakePrintersRepository(
      watchResponses: [
        StateError('boom'),
        <PrinterModel>[_printer()],
      ],
    );
    final db = await tester.pumpApp(const Printers(), [
      printersRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    expect(find.textContaining('Failed to load printers'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Prusa MK4'), findsOneWidget);
    expect(repo.getPrinterByIdCalls, isEmpty);
  });

  testWidgets('delete action calls repository delete', (tester) async {
    final printer = _printer();
    final repo = FakePrintersRepository(
      watchResponses: [
        <PrinterModel>[printer],
      ],
    );
    repo.printersById[printer.id] = printer;

    final db = await tester.pumpApp(const Printers(), [
      printersRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings.printers.item.0')),
        matching: find.byIcon(Icons.delete),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(repo.deleteCalls, ['printer-1']);
  });

  testWidgets('edit action opens AddPrinter with the printer id', (
    tester,
  ) async {
    final printer = _printer();
    final repo = FakePrintersRepository(
      watchResponses: [
        <PrinterModel>[printer],
      ],
    );
    repo.printersById[printer.id] = printer;

    final db = await tester.pumpApp(const Printers(), [
      printersRepositoryProvider.overrideWithValue(repo),
    ]);
    addTearDown(db.close);

    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const ValueKey<String>('settings.printers.item.0')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const ValueKey<String>('settings.printers.item.0.edit.button'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.getPrinterByIdCalls, ['printer-1']);
    expect(
      tester
          .widget<TextFormField>(_field('settings.printers.name.input'))
          .controller!
          .text,
      'Prusa MK4',
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.printers.bedSize.input'))
          .controller!
          .text,
      '250x210x220',
    );
    expect(
      tester
          .widget<TextFormField>(_field('settings.printers.wattage.input'))
          .controller!
          .text,
      '350',
    );
  });
}
