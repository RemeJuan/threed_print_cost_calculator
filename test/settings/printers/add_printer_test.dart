import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/printers/add_printer.dart';
import '../settings_test_fakes.dart';

import '../../helpers/helpers.dart';

Finder _field(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(TextFormField),
  );
}

class _PrinterDialogHost extends StatelessWidget {
  const _PrinterDialogHost({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await showDialog<void>(context: context, builder: builder);
          },
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('typing updates notifier state and save closes the dialog', (
    tester,
  ) async {
    final repo = FakePrintersRepository();
    final db = await tester.pumpApp(
      _PrinterDialogHost(builder: (_) => const AddPrinter()),
      [printersRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.printers.name.input'), 'Prusa MK4');
    await tester.enterText(
      _field('settings.printers.bedSize.input'),
      '250x210x220',
    );
    await tester.enterText(_field('settings.printers.wattage.input'), '350');

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

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.printers.save.button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    expect(repo.savedPrinters, hasLength(1));
    expect(repo.savedPrinters.single.name, 'Prusa MK4');
    expect(repo.savedPrinters.single.bedSize, '250x210x220');
    expect(repo.savedPrinters.single.wattage, '350');
  });

  testWidgets('invalid values block save and show localized errors', (
    tester,
  ) async {
    final repo = FakePrintersRepository();
    final db = await tester.pumpApp(
      _PrinterDialogHost(builder: (_) => const AddPrinter()),
      [printersRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(_field('settings.printers.name.input'), 'Prusa MK4');
    await tester.enterText(_field('settings.printers.bedSize.input'), '0');
    await tester.enterText(_field('settings.printers.wattage.input'), '0');

    await tester.tap(
      find.byKey(const ValueKey<String>('settings.printers.save.button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Must be greater than 0'), findsNWidgets(2));
    expect(repo.savedPrinters, isEmpty);
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('edit mode preloads once and rebuilds preserve edits', (
    tester,
  ) async {
    final printer = const PrinterModel(
      id: 'printer-1',
      name: 'Prusa MK4',
      bedSize: '250x210x220',
      wattage: '350',
      archived: false,
    );
    final repo = FakePrintersRepository();
    repo.printersById[printer.id] = printer;

    final db = await tester.pumpApp(
      _PrinterDialogHost(builder: (_) => const AddPrinter(dbRef: 'printer-1')),
      [printersRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(db.close);

    await tester.tap(find.text('Open'));
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

    await tester.enterText(
      _field('settings.printers.name.input'),
      'Prusa MK4 Edit',
    );
    await tester.pumpAndSettle();

    expect(repo.getPrinterByIdCalls, ['printer-1']);
    expect(
      tester
          .widget<TextFormField>(_field('settings.printers.name.input'))
          .controller!
          .text,
      'Prusa MK4 Edit',
    );
  });
}
