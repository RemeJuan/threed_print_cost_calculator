import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/services/electricity_resolver.dart';
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
        if (usage.materialId.startsWith(
          MaterialUsageInput.unsavedMaterialIdPrefix,
        )) {
          resolvedMaterial = null;
        } else {
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

    final markupPercent = entry.model.pricingMarkupPercent;
    final setupFee = entry.model.pricingSetupFee;
    final roundingMode = pricingRoundingModeFromStorage(
      entry.model.pricingRoundingMode,
    );
    final pricing = entry.model.finalPrice == null
        ? const PricingResult.empty()
        : PricingResult(
            baseCost: entry.model.totalCost,
            markupPercent: markupPercent ?? 0,
            markupAmount: entry.model.pricingMarkupAmount ?? 0,
            setupFee: setupFee ?? 0,
            roundingMode: roundingMode,
            subtotalBeforeRounding:
                entry.model.pricingSubtotalBeforeRounding ??
                entry.model.totalCost,
            roundingAdjustment: entry.model.pricingRoundingAdjustment ?? 0,
            finalPrice: entry.model.finalPrice ?? entry.model.totalCost,
          );

    final WattageSource storedSource;
    switch (entry.model.electricitySource) {
      case 'average':
        storedSource = WattageSource.average;
      default:
        storedSource = WattageSource.rated;
    }

    final resolvedWattage = _resolveLoadedWattage(
      resolvedPrinter: resolvedPrinter,
      settings: settings,
      storedSource: storedSource,
    );

    final nextState = CalculatorState(
      activePrinterId: resolvedPrinter?.id ?? settings.activePrinter,
      selectedMaterialId: materialUsages.isNotEmpty
          ? materialUsages.first.materialId
          : '',
      watt: NumberInput.dirty(
        value: resolvedWattage,
      ),
      wattageSource: storedSource,
      kwCost: currentState.kwCost,
      printWeight: NumberInput.dirty(value: entry.model.weight),
      materialUsages: materialUsages,
      hours: NumberInput.dirty(value: parsedTime.hours),
      minutes: NumberInput.dirty(value: parsedTime.minutes),
      spoolWeight: currentState.spoolWeight,
      spoolCost: currentState.spoolCost,
      spoolCostText: currentState.spoolCostText,
      additionalCostAmount: NumberInput.dirty(
        value: entry.model.additionalCostAmount,
      ),
      additionalCostNote: entry.model.additionalCostNote,
      wearAndTear: NumberInput.dirty(value: currentState.baselineWearAndTear),
      failureRisk: NumberInput.dirty(value: currentState.baselineFailureRisk),
      labourRate: NumberInput.dirty(value: currentState.baselineLabourRate),
      labourTime: NumberInput.dirty(value: currentState.baselineLabourTime),
      markupPercent: NumberInput.dirty(value: markupPercent),
      markupPercentOverridden: true,
      setupFee: NumberInput.dirty(value: setupFee),
      roundingMode: roundingMode,
      results: CalculationResult(
        electricity: entry.model.electricityCost,
        filament: entry.model.filamentCost,
        risk: entry.model.riskCost,
        labour: entry.model.labourCost,
        total: entry.model.totalCost,
        electricitySource: storedSource,
      ),
      pricing: pricing,
      showHistoryLoadReplacementWarning: hasReplacement,
      importedFromGcode: entry.model.importedFromGcode,
      hasHydratedDefaults: true,
      baselineWearAndTear: currentState.baselineWearAndTear,
      baselineFailureRisk: currentState.baselineFailureRisk,
      baselineLabourRate: currentState.baselineLabourRate,
      baselineLabourTime: currentState.baselineLabourTime,
      baselineMarkupPercent: markupPercent,
      baselineSetupFee: setupFee,
      baselineRoundingMode: roundingMode,
    );

    return CalculatorHistoryLoadResult(
      state: nextState,
      activePrinterId: resolvedPrinter?.id ?? settings.activePrinter,
      selectedMaterialId: materialUsages.isNotEmpty &&
              !materialUsages.first.materialId.startsWith(
                MaterialUsageInput.unsavedMaterialIdPrefix,
              )
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

  num _resolveLoadedWattage({
    required PrinterModel? resolvedPrinter,
    required GeneralSettingsModel settings,
    required WattageSource storedSource,
  }) {
    if (resolvedPrinter != null) {
      final preferred = storedSource == WattageSource.average
          ? tryParseLocalizedNum(resolvedPrinter.averageWattage)
          : tryParseLocalizedNum(resolvedPrinter.wattage);
      if (preferred != null) return preferred;

      final fallbackResolution = ref
          .read(electricityResolverProvider)
          .resolveFromPrinter(resolvedPrinter);
      return fallbackResolution.wattage;
    }

    final preferred = storedSource == WattageSource.average
        ? tryParseLocalizedNum(settings.averageWattage)
        : tryParseLocalizedNum(settings.wattage);
    if (preferred != null) return preferred;

    final fallbackResolution = ref.read(electricityResolverProvider).resolve(
      printers: const [],
      activePrinterId: settings.activePrinter,
      settings: settings,
    );
    return fallbackResolution.wattage;
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
