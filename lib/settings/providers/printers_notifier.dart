import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
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

  FieldValidationError? validateName(String? value) {
    return validateRequiredText(value);
  }

  FieldValidationError? validateBedSize(String? value) {
    return validatePrinterBedSize(value);
  }

  FieldValidationError? validateWattage(String? value) {
    return validatePositiveNumber(value);
  }

  FieldValidationError? validateAverageWattage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return validatePositiveNumber(value);
  }

  Future<void> init(String? key) async {
    if (key != null) {
      final printer = await _printersRepository.getPrinterById(key);
      if (printer == null) return;

      updateName(printer.name);
      updateBedSize(printer.bedSize);
      updateWattage(printer.wattage);
      updateAverageWattage(printer.averageWattage);
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

  void updateAverageWattage(String value) {
    state = state.copyWith(averageWattage: StringInput.dirty(value: value));
  }

  Future<bool> submit(String? dbRef) async {
    if (!isValidForSubmit) {
      return false;
    }

    if (dbRef == null) {
      final count = await _printersRepository.count();
      final access = ref
          .read(premiumAccessPolicyProvider)
          .canCreatePrinter(count);
      if (!access.allowed) {
        return false;
      }
    }

    final printer = PrinterModel(
      id: dbRef ?? '',
      name: state.name.value.trim(),
      bedSize: state.bedSize.value.trim(),
      wattage: state.wattage.value.trim(),
      averageWattage: state.averageWattage.value.trim(),
      archived: false,
    );

    await _printersRepository.savePrinter(printer, id: dbRef);
    AppAnalytics.safeLog(AppAnalytics.printerProfileCreated);
    return true;
  }

  bool get isValidForSubmit {
    return validateName(state.name.value) == null &&
        validateBedSize(state.bedSize.value) == null &&
        validateWattage(state.wattage.value) == null &&
        validateAverageWattage(state.averageWattage.value) == null;
  }
}
