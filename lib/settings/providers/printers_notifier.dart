import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/string_input.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/state/printer_state.dart';

final printersProvider =
    NotifierProvider<PrintersNotifier, PrinterState>(PrintersNotifier.new);

class PrintersNotifier extends Notifier<PrinterState> {
  @override
  PrinterState build() {
    return PrinterState();
  }

  DataBaseHelpers get dbHelpers => ref.read(dbHelpersProvider(DBName.printers));

  void init(String? key) async {
    if (key != null) {
      final record = await dbHelpers.getRecord(key);

      final printer = PrinterModel.fromMap(
        // ignore: cast_nullable_to_non_nullable
        record!.value as Map<String, dynamic>,
        key,
      );

      updateName(printer.name);
      updateBedSize(printer.bedSize);
      updateWattage(printer.wattage);
    }
  }

  void updateName(String value) {
    state = state.copyWith(name: StringInput.dirty(value: value));
  }

  void updateBedSize(String value) {
    state = state.copyWith(
      bedSize: StringInput.dirty(value: value),
    );
  }

  void updateWattage(String value) {
    state = state.copyWith(wattage: StringInput.dirty(value: value));
  }

  void submit(String? dbRef) {
    final data = {
      'name': state.name.value,
      'bedSize': state.bedSize.value,
      'wattage': state.wattage.value,
    };

    if (dbRef != null) {
      dbHelpers.updateRecord(dbRef, data);
    } else {
      dbHelpers.insertRecord(data);
    }
  }
}
