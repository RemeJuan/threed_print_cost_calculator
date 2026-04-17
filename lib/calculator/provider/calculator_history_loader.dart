import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final calculatorHistoryLoaderProvider = Provider<CalculatorHistoryLoader>(
  CalculatorHistoryLoader.new,
);

class CalculatorHistoryLoader {
  CalculatorHistoryLoader(this.ref);

  final Ref ref;

  Future<CalculatorHistoryLoadResult?> load({
    required HistoryEntry entry,
    required CalculatorState currentState,
    required GeneralSettingsModel settings,
  }) async {
    final parsedTime = _parseHistoryTime(entry.model.timeHours);
    if (parsedTime == null) return null;

    final resolvedPrinter = await _resolvePrinter(
      entry.model.printer,
      settings,
    );
    final fallbackMaterial = await _resolveFallbackMaterial();

    var hasReplacement =
        entry.model.printer.isNotEmpty &&
        resolvedPrinter != null &&
        resolvedPrinter.name != entry.model.printer;

    final materialsRepository = ref.read(materialsRepositoryProvider);
    final materialUsages = <MaterialUsageInput>[];

    for (final rawUsage in entry.model.materialUsages) {
      final usage = MaterialUsageInput.fromMap(rawUsage);
      var resolvedUsage = usage;
      MaterialModel? resolvedMaterial;
      final rawCostPerKg = rawUsage['costPerKg'];
      final shouldBackfillCost =
          !rawUsage.containsKey('costPerKg') ||
          rawCostPerKg == null ||
          rawCostPerKg.toString().trim().isEmpty ||
          (entry.model.materialUsages.length == 1 &&
              parseLocalizedNumOrFallback(rawCostPerKg) == 0 &&
              entry.model.filamentCost > 0);

      if (usage.materialId.trim().isNotEmpty) {
        final material = await materialsRepository.getMaterialById(
          usage.materialId,
        );
        if (material == null && fallbackMaterial != null) {
          hasReplacement = true;
          resolvedMaterial = fallbackMaterial;
          resolvedUsage = usage.copyWith(
            materialId: fallbackMaterial.id,
            materialName: fallbackMaterial.name,
          );
        } else {
          resolvedMaterial = material;
        }
      }

      if (shouldBackfillCost && resolvedMaterial != null) {
        resolvedUsage = resolvedUsage.copyWith(
          costPerKg: _costPerKgFromSpool(
            spoolWeight: parseLocalizedNumOrFallback(resolvedMaterial.weight),
            spoolCost: parseLocalizedNumOrFallback(resolvedMaterial.cost),
          ),
        );
      }

      materialUsages.add(resolvedUsage);
    }

    final nextState = currentState.copyWith(
      watt: NumberInput.dirty(
        value: parseLocalizedNumOrFallback(
          resolvedPrinter?.wattage ?? settings.wattage,
        ),
      ),
      printWeight: NumberInput.dirty(value: entry.model.weight),
      materialUsages: materialUsages,
      hours: NumberInput.dirty(value: parsedTime.hours),
      minutes: NumberInput.dirty(value: parsedTime.minutes),
      results: CalculationResult(
        electricity: entry.model.electricityCost,
        filament: entry.model.filamentCost,
        risk: entry.model.riskCost,
        labour: entry.model.labourCost,
        total: entry.model.totalCost,
      ),
      showHistoryLoadReplacementWarning: hasReplacement,
    );

    return CalculatorHistoryLoadResult(
      state: nextState,
      activePrinterId: resolvedPrinter?.id ?? settings.activePrinter,
      selectedMaterialId: materialUsages.isNotEmpty
          ? materialUsages.first.materialId
          : null,
    );
  }

  ({int hours, int minutes})? _parseHistoryTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) return null;

    return (hours: hours, minutes: minutes);
  }

  Future<PrinterModel?> _resolvePrinter(
    String printerName,
    GeneralSettingsModel settings,
  ) async {
    final printersRepository = ref.read(printersRepositoryProvider);
    final printers = await printersRepository.getPrinters();

    for (final printer in printers) {
      if (printer.name == printerName) return printer;
    }

    if (settings.activePrinter.isNotEmpty) {
      final activePrinter = await printersRepository.getPrinterById(
        settings.activePrinter,
      );
      if (activePrinter != null) return activePrinter;
    }

    if (printers.isEmpty) return null;
    return printers.first;
  }

  Future<MaterialModel?> _resolveFallbackMaterial() async {
    final materials = await ref
        .read(materialsRepositoryProvider)
        .getMaterials();
    if (materials.isEmpty) return null;
    return materials.first;
  }

  num _costPerKgFromSpool({required num spoolWeight, required num spoolCost}) {
    return spoolWeight <= 0 ? 0 : (spoolCost / spoolWeight) * 1000;
  }
}

class CalculatorHistoryLoadResult {
  const CalculatorHistoryLoadResult({
    required this.state,
    required this.activePrinterId,
    required this.selectedMaterialId,
  });

  final CalculatorState state;
  final String activePrinterId;
  final String? selectedMaterialId;
}
