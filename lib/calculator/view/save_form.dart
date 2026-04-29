import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

class SaveForm extends HookConsumerWidget {
  final CalculationResult data;
  final PricingResult pricing;
  final ValueNotifier<bool> showSave;

  const SaveForm({
    required this.data,
    this.pricing = const PricingResult.empty(),
    required this.showSave,
    super.key,
  });

  @override
  Widget build(context, ref) {
    final name = useState<String>('');
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey<String>('calculator.save.name.input'),
              decoration: InputDecoration(hintText: l10n.printNameHint),
              onChanged: (value) {
                name.value = value;
              },
            ),
          ),
          IconButton(
            key: const ValueKey<String>('calculator.save.confirm.button'),
            onPressed: name.value.isEmpty
                ? null
                : () async {
                    final settings = await ref
                        .read(settingsServiceProvider)
                        .get();

                    String printerName = '';
                    String materialName = '';

                    if (settings.activePrinter.isNotEmpty) {
                      final printer = await ref
                          .read(printersRepositoryProvider)
                          .getPrinterById(settings.activePrinter);
                      printerName = printer?.name ?? '';
                    }

                    // Read calculator state for weight and time
                    final calcState = ref.read(calculatorProvider);

                    final num materialsSum = calcState.materialUsages.fold<int>(
                      0,
                      (sum, usage) => sum + usage.weightGrams,
                    );

                    final num weightVal = materialsSum == 0
                        ? (calcState.printWeight.value ?? 0)
                        : materialsSum;

                    final usages = calcState.materialUsages
                        .map((usage) => usage.toMap())
                        .toList();

                    if (calcState.materialUsages.isNotEmpty) {
                      final firstName =
                          calcState.materialUsages.first.materialName;
                      final count = calcState.materialUsages.length;
                      materialName = count > 1
                          ? '$firstName +${count - 1}'
                          : firstName;
                    } else if (settings.selectedMaterial.isNotEmpty) {
                      final material = await ref
                          .read(materialsRepositoryProvider)
                          .getMaterialById(settings.selectedMaterial);
                      if (material != null) {
                        final spoolWeight = parseLocalizedNumOrFallback(
                          material.weight,
                        );
                        final spoolCost = parseLocalizedNumOrFallback(
                          material.cost,
                        );
                        final costPerKg = spoolWeight <= 0
                            ? 0
                            : (spoolCost / spoolWeight) * 1000;
                        materialName = material.name;
                        usages.add(
                          MaterialUsageInput(
                            materialId: settings.selectedMaterial,
                            materialName: materialName,
                            costPerKg: costPerKg,
                            weightGrams: weightVal.toInt(),
                          ).toMap(),
                        );
                      }
                    }
                    final int hours = (calcState.hours.value ?? 0).toInt();
                    final int minutes = (calcState.minutes.value ?? 0).toInt();

                    String twoDigits(int n) => n.toString().padLeft(2, '0');
                    final timeStr = '${twoDigits(hours)}:${twoDigits(minutes)}';
                    final hasOverrides =
                        !_sameNum(
                          calcState.wearAndTear.value ?? 0,
                          tryParseLocalizedNum(settings.wearAndTear) ?? 0,
                        ) ||
                        !_sameNum(
                          calcState.failureRisk.value ?? 0,
                          tryParseLocalizedNum(settings.failureRisk) ?? 0,
                        ) ||
                        !_sameNum(
                          calcState.labourRate.value ?? 0,
                          tryParseLocalizedNum(settings.labourRate) ?? 0,
                        ) ||
                        !_sameNum(
                          calcState.markupPercent.value ?? 0,
                          tryParseLocalizedNum(settings.pricingMarkupPercent) ??
                              0,
                        ) ||
                        (calcState.labourTime.value ?? 0) > 0;

                    final model = HistoryModel(
                      name: name.value,
                      electricityCost: data.electricity,
                      filamentCost: data.filament,
                      totalCost: data.total,
                      riskCost: data.risk,
                      labourCost: data.labour,
                      date: DateTime.now(),
                      printer: printerName,
                      material: materialName,
                      weight: weightVal,
                      materialUsages: usages,
                      timeHours: timeStr,
                      importedFromGcode: calcState.importedFromGcode,
                      pricingMarkupPercent: pricing.isEnabled
                          ? pricing.markupPercent
                          : null,
                      pricingMarkupAmount: pricing.isEnabled
                          ? pricing.markupAmount
                          : null,
                      pricingSetupFee: pricing.isEnabled ? pricing.setupFee : null,
                      pricingRoundingMode: pricing.isEnabled
                          ? pricing.roundingMode.storageValue
                          : null,
                      pricingSubtotalBeforeRounding: pricing.isEnabled
                          ? pricing.subtotalBeforeRounding
                          : null,
                      pricingRoundingAdjustment: pricing.isEnabled
                          ? pricing.roundingAdjustment
                          : null,
                      finalPrice: pricing.isEnabled ? pricing.finalPrice : null,
                      pricingUsedOverrides: hasOverrides,
                    );
                    await ref
                        .read(calculatorHelpersProvider)
                        .savePrint(
                          model,
                          errorMessage: l10n.savePrintErrorMessage,
                          successMessage: l10n.savePrintSuccessMessage,
                        );
                    AppAnalytics.safeLog(
                      () => AppAnalytics.pricingSaved(
                        hasPricing: pricing.isEnabled,
                        usedOverrides: hasOverrides,
                        roundingMode: pricing.roundingMode.storageValue,
                      ),
                    );
                    showSave.value = false;
                  },
            icon: const Icon(Icons.save),
          ),
          IconButton(
            key: const ValueKey<String>('calculator.save.cancel.button'),
            onPressed: () {
              showSave.value = false;
            },
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
    );
  }

  bool _sameNum(num a, num b) => (a - b).abs() < 0.001;
}
