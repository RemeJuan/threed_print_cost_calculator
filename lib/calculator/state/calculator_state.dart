import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage_input.dart';
import 'package:threed_print_cost_calculator/calculator/model/pricing_models.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';

const _unsetCalculatorStateValue = Object();

class CalculatorState with FormzMixin {
  final String activePrinterId;
  final String selectedMaterialId;
  final NumberInput watt;
  final NumberInput kwCost;
  final NumberInput printWeight;
  final List<MaterialUsageInput> materialUsages;
  final NumberInput hours;
  final NumberInput minutes;
  final NumberInput spoolWeight;
  final NumberInput spoolCost;
  final String spoolCostText;
  final NumberInput wearAndTear;
  final NumberInput failureRisk;
  final NumberInput labourRate;
  final NumberInput labourTime;
  final NumberInput additionalCostAmount;
  final String? additionalCostNote;
  final NumberInput markupPercent;
  final NumberInput setupFee;
  final PricingRoundingMode roundingMode;
  final CalculationResult results;
  final PricingResult pricing;
  final bool showHistoryLoadReplacementWarning;
  final bool importedFromGcode;
  final bool hasHydratedDefaults;
  final num? baselineWearAndTear;
  final num? baselineFailureRisk;
  final num? baselineLabourRate;
  final num baselineLabourTime;
  final num? baselineMarkupPercent;
  final num? baselineSetupFee;
  final PricingRoundingMode baselineRoundingMode;

  CalculatorState({
    this.activePrinterId = '',
    this.selectedMaterialId = '',
    this.watt = const NumberInput.pure(),
    this.kwCost = const NumberInput.pure(),
    this.printWeight = const NumberInput.pure(),
    List<MaterialUsageInput>? materialUsages,
    this.hours = const NumberInput.pure(),
    this.minutes = const NumberInput.pure(),
    this.spoolWeight = const NumberInput.pure(),
    this.spoolCost = const NumberInput.pure(),
    this.spoolCostText = '',
    this.wearAndTear = const NumberInput.pure(),
    this.failureRisk = const NumberInput.pure(),
    this.labourRate = const NumberInput.pure(),
    this.labourTime = const NumberInput.pure(),
    this.additionalCostAmount = const NumberInput.pure(),
    this.additionalCostNote,
    this.markupPercent = const NumberInput.pure(),
    this.setupFee = const NumberInput.pure(),
    this.roundingMode = PricingRoundingMode.none,
    this.results = const CalculationResult(
      electricity: 0.0,
      filament: 0.0,
      risk: 0.0,
      labour: 0.0,
      total: 0.0,
    ),
    this.pricing = const PricingResult.empty(),
    this.showHistoryLoadReplacementWarning = false,
    this.importedFromGcode = false,
    this.hasHydratedDefaults = false,
    this.baselineWearAndTear,
    this.baselineFailureRisk,
    this.baselineLabourRate,
    this.baselineLabourTime = 0,
    this.baselineMarkupPercent,
    this.baselineSetupFee,
    this.baselineRoundingMode = PricingRoundingMode.none,
  }) : materialUsages = List.unmodifiable(
         materialUsages ?? const <MaterialUsageInput>[],
       );

  CalculatorState copyWith({
    String? activePrinterId,
    String? selectedMaterialId,
    NumberInput? watt,
    NumberInput? kwCost,
    NumberInput? printWeight,
    List<MaterialUsageInput>? materialUsages,
    NumberInput? hours,
    NumberInput? minutes,
    NumberInput? spoolWeight,
    NumberInput? spoolCost,
    String? spoolCostText,
    NumberInput? wearAndTear,
    NumberInput? failureRisk,
    NumberInput? labourRate,
    NumberInput? labourTime,
    NumberInput? additionalCostAmount,
    Object? additionalCostNote = _unsetCalculatorStateValue,
    NumberInput? markupPercent,
    NumberInput? setupFee,
    PricingRoundingMode? roundingMode,
    CalculationResult? results,
    PricingResult? pricing,
    bool? showHistoryLoadReplacementWarning,
    bool? importedFromGcode,
    bool? hasHydratedDefaults,
    Object? baselineWearAndTear = _unsetCalculatorStateValue,
    Object? baselineFailureRisk = _unsetCalculatorStateValue,
    Object? baselineLabourRate = _unsetCalculatorStateValue,
    num? baselineLabourTime,
    Object? baselineMarkupPercent = _unsetCalculatorStateValue,
    Object? baselineSetupFee = _unsetCalculatorStateValue,
    PricingRoundingMode? baselineRoundingMode,
  }) {
    return CalculatorState(
      activePrinterId: activePrinterId ?? this.activePrinterId,
      selectedMaterialId: selectedMaterialId ?? this.selectedMaterialId,
      watt: watt ?? this.watt,
      kwCost: kwCost ?? this.kwCost,
      printWeight: printWeight ?? this.printWeight,
      materialUsages: List.unmodifiable(materialUsages ?? this.materialUsages),
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      spoolWeight: spoolWeight ?? this.spoolWeight,
      spoolCost: spoolCost ?? this.spoolCost,
      spoolCostText: spoolCostText ?? this.spoolCostText,
      wearAndTear: wearAndTear ?? this.wearAndTear,
      failureRisk: failureRisk ?? this.failureRisk,
      labourRate: labourRate ?? this.labourRate,
      labourTime: labourTime ?? this.labourTime,
      additionalCostAmount: additionalCostAmount ?? this.additionalCostAmount,
      additionalCostNote:
          identical(additionalCostNote, _unsetCalculatorStateValue)
          ? this.additionalCostNote
          : additionalCostNote as String?,
      markupPercent: markupPercent ?? this.markupPercent,
      setupFee: setupFee ?? this.setupFee,
      roundingMode: roundingMode ?? this.roundingMode,
      results: results ?? this.results,
      pricing: pricing ?? this.pricing,
      showHistoryLoadReplacementWarning:
          showHistoryLoadReplacementWarning ??
          this.showHistoryLoadReplacementWarning,
      importedFromGcode: importedFromGcode ?? this.importedFromGcode,
      hasHydratedDefaults: hasHydratedDefaults ?? this.hasHydratedDefaults,
      baselineWearAndTear:
          identical(baselineWearAndTear, _unsetCalculatorStateValue)
          ? this.baselineWearAndTear
          : baselineWearAndTear as num?,
      baselineFailureRisk:
          identical(baselineFailureRisk, _unsetCalculatorStateValue)
          ? this.baselineFailureRisk
          : baselineFailureRisk as num?,
      baselineLabourRate:
          identical(baselineLabourRate, _unsetCalculatorStateValue)
          ? this.baselineLabourRate
          : baselineLabourRate as num?,
      baselineLabourTime: baselineLabourTime ?? this.baselineLabourTime,
      baselineMarkupPercent:
          identical(baselineMarkupPercent, _unsetCalculatorStateValue)
          ? this.baselineMarkupPercent
          : baselineMarkupPercent as num?,
      baselineSetupFee: identical(baselineSetupFee, _unsetCalculatorStateValue)
          ? this.baselineSetupFee
          : baselineSetupFee as num?,
      baselineRoundingMode: baselineRoundingMode ?? this.baselineRoundingMode,
    );
  }

  @override
  List<FormzInput> get inputs => [
    watt,
    kwCost,
    printWeight,
    hours,
    minutes,
    spoolWeight,
    spoolCost,
    wearAndTear,
    failureRisk,
    labourRate,
    labourTime,
    additionalCostAmount,
    markupPercent,
    setupFee,
  ];
}
