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

  NumberInput _settingsNumber(String? settingsValue) {
    return NumberInput.dirty(value: tryParseLocalizedNum(settingsValue));
  }

  Future<CalculatorState> load(
    GeneralSettingsModel settings, {
    bool seedInitialMaterialUsage = false,
  }) async {
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
      activePrinterId: settings.activePrinter,
      selectedMaterialId: '',
      watt: NumberInput.dirty(value: watt),
      kwCost: _settingsNumber(settings.electricityCost),
      spoolWeight: NumberInput.dirty(
        value: tryParseLocalizedNum(spoolWeightVal),
      ),
      spoolCost: NumberInput.dirty(value: tryParseLocalizedNum(spoolCostVal)),
      spoolCostText: spoolCostVal,
      wearAndTear: _settingsNumber(settings.wearAndTear),
      failureRisk: _settingsNumber(settings.failureRisk),
      labourRate: _settingsNumber(settings.labourRate),
      markupPercent: _settingsNumber(settings.pricingMarkupPercent),
      setupFee: _settingsNumber(settings.pricingSetupFee),
      roundingMode: pricingRoundingModeFromStorage(
        settings.pricingRoundingMode,
      ),
      hasHydratedDefaults: true,
      baselineWearAndTear: tryParseLocalizedNum(settings.wearAndTear),
      baselineFailureRisk: tryParseLocalizedNum(settings.failureRisk),
      baselineLabourRate: tryParseLocalizedNum(settings.labourRate),
      baselineLabourTime: 0,
      baselineMarkupPercent: tryParseLocalizedNum(
        settings.pricingMarkupPercent,
      ),
      baselineSetupFee: tryParseLocalizedNum(settings.pricingSetupFee),
      baselineRoundingMode: pricingRoundingModeFromStorage(
        settings.pricingRoundingMode,
      ),
    );

    if (!seedInitialMaterialUsage) return nextState;
    if (spoolWeightVal.trim().isNotEmpty || spoolCostVal.trim().isNotEmpty) {
      return nextState;
    }

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
