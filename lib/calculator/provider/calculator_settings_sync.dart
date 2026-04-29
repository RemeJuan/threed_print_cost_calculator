import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:threed_print_cost_calculator/database/repositories/calculator_preferences_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final calculatorSettingsSyncProvider = Provider<CalculatorSettingsSync>(
  CalculatorSettingsSync.new,
);

class CalculatorSettingsSync {
  CalculatorSettingsSync(this.ref);

  final Ref ref;

  Future<CalculatorState> load(
    CalculatorState current,
    GeneralSettingsModel settings,
  ) async {
    final preferencesRepository = ref.read(
      calculatorPreferencesRepositoryProvider,
    );
    final printerKey = settings.activePrinter;

    final spoolWeightVal = await preferencesRepository.getStringValue(
      'spoolWeight',
    );
    final spoolCostVal = await preferencesRepository.getStringValue(
      'spoolCost',
    );

    var watt = tryParseLocalizedNum(settings.wattage);
    if (printerKey.isNotEmpty) {
      final printer = await ref
          .read(printersRepositoryProvider)
          .getPrinterById(printerKey);
      if (printer != null) {
        final parsedWatt = tryParseLocalizedNum(printer.wattage);
        if (parsedWatt != null) {
          watt = parsedWatt;
        }
      }
    }

    final nextState = CalculatorState(
      watt: NumberInput.dirty(value: watt),
      kwCost: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.electricityCost),
      ),
      printWeight: NumberInput.dirty(value: current.printWeight.value),
      hours: NumberInput.dirty(value: current.hours.value),
      minutes: NumberInput.dirty(value: current.minutes.value),
      spoolWeight: NumberInput.dirty(
        value: tryParseLocalizedNum(spoolWeightVal),
      ),
      spoolCost: NumberInput.dirty(value: tryParseLocalizedNum(spoolCostVal)),
      spoolCostText: spoolCostVal,
      wearAndTear: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.wearAndTear),
      ),
      failureRisk: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.failureRisk),
      ),
      labourRate: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.labourRate),
      ),
      labourTime: NumberInput.dirty(value: current.labourTime.value),
      markupPercent: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.pricingMarkupPercent),
      ),
      setupFee: NumberInput.dirty(
        value: tryParseLocalizedNum(settings.pricingSetupFee),
      ),
      roundingMode: pricingRoundingModeFromStorage(
        settings.pricingRoundingMode,
      ),
      materialUsages: current.materialUsages,
      results: current.results,
      pricing: current.pricing,
    );

    return ensureInitialMaterialUsage(nextState, settings.selectedMaterial);
  }

  Future<CalculatorState> ensureInitialMaterialUsage(
    CalculatorState state,
    String selectedMaterialId,
  ) async {
    if (state.materialUsages.isNotEmpty) return state;
    if (selectedMaterialId.isEmpty) {
      return state.copyWith(materialUsages: []);
    }

    final material = await ref
        .read(materialsRepositoryProvider)
        .getMaterialById(selectedMaterialId);
    if (material == null) {
      return state.copyWith(materialUsages: []);
    }

    final weight = parseLocalizedNumOrFallback(material.weight);
    final cost = parseLocalizedNumOrFallback(material.cost);
    final costPerKg = _costPerKgFromSpool(spoolWeight: weight, spoolCost: cost);

    return state.copyWith(
      materialUsages: [
        MaterialUsageInput(
          materialId: material.id,
          materialName: material.name,
          costPerKg: costPerKg,
          weightGrams: (state.printWeight.value ?? 0).toInt(),
        ),
      ],
    );
  }

  num _costPerKgFromSpool({required num spoolWeight, required num spoolCost}) {
    return spoolWeight <= 0 ? 0 : (spoolCost / spoolWeight) * 1000;
  }
}
