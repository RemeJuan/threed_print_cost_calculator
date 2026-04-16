import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/state/printer_state.dart';
import 'package:threed_print_cost_calculator/shared/utils/form_validation.dart';

final printersProvider = NotifierProvider<PrintersNotifier, PrinterState>(
  PrintersNotifier.new,
);

class PrintersNotifier extends Notifier<PrinterState> {
  @override
  PrinterState build() {
    return PrinterState();
  }

  PrintersRepository get _printersRepository =>
      ref.read(printersRepositoryProvider);

  void init(String? key) async {
    if (key != null) {
      final printer = await _printersRepository.getPrinterById(key);
      if (printer == null) return;

      updateName(printer.name);
      updateBedSize(printer.bedSize);
      updateWattage(printer.wattage);
    }
  }

  void updateName(String value) {
    state = state.copyWith(name: StringInput.dirty(value: value));
  }

  void updateBedSize(String value) {
    state = state.copyWith(bedSize: StringInput.dirty(value: value));
  }

  void updateWattage(String value) {
    state = state.copyWith(wattage: StringInput.dirty(value: value));
  }

  Future<bool> submit(String? dbRef) async {
    if (!_isValidForSubmit) {
      return false;
    }

    final printer = PrinterModel(
      id: dbRef ?? '',
      name: state.name.value.trim(),
      bedSize: state.bedSize.value.trim(),
      wattage: state.wattage.value.trim(),
      archived: false,
    );

    await _printersRepository.savePrinter(printer, id: dbRef);
    AppAnalytics.safeLog(AppAnalytics.printerProfileCreated);
    return true;
  }

  bool get _isValidForSubmit {
    return validateRequiredText(state.name.value) == null &&
        validatePrinterBedSize(state.bedSize.value) == null &&
        validatePositiveNumber(state.wattage.value) == null;
  }
}
