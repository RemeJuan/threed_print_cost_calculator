import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';

class CalculatorState with FormzMixin {
  final NumberInput watt;
  final NumberInput kwCost;
  final NumberInput printWeight;
  final NumberInput hours;
  final NumberInput minutes;
  final NumberInput spoolWeight;
  final NumberInput spoolCost;
  final String spoolCostText; // Raw text input for spool cost
  final NumberInput wearAndTear;
  final NumberInput failureRisk;
  final NumberInput labourRate;
  final NumberInput labourTime;
  final CalculationResult results;
  /// Multi-material usages for the current calculation.
  /// When non-empty, the filament cost is computed from these usages.
  /// When empty, the legacy spoolWeight/spoolCost/printWeight fields are used.
  final List<MaterialUsage> materialUsages;

  CalculatorState({
    this.watt = const NumberInput.pure(),
    this.kwCost = const NumberInput.pure(),
    this.printWeight = const NumberInput.pure(),
    this.hours = const NumberInput.pure(),
    this.minutes = const NumberInput.pure(),
    this.spoolWeight = const NumberInput.pure(),
    this.spoolCost = const NumberInput.pure(),
    this.spoolCostText = '',
    this.wearAndTear = const NumberInput.pure(),
    this.failureRisk = const NumberInput.pure(),
    this.labourRate = const NumberInput.pure(),
    this.labourTime = const NumberInput.pure(),
    this.results = const CalculationResult(
      electricity: 0.0,
      filament: 0.0,
      risk: 0.0,
      labour: 0.0,
      total: 0.0,
    ),
    this.materialUsages = const <MaterialUsage>[],
  });

  CalculatorState copyWith({
    NumberInput? watt,
    NumberInput? kwCost,
    NumberInput? printWeight,
    NumberInput? hours,
    NumberInput? minutes,
    NumberInput? spoolWeight,
    NumberInput? spoolCost,
    String? spoolCostText,
    NumberInput? wearAndTear,
    NumberInput? failureRisk,
    NumberInput? labourRate,
    NumberInput? labourTime,
    CalculationResult? results,
    List<MaterialUsage>? materialUsages,
  }) {
    return CalculatorState(
      watt: watt ?? this.watt,
      kwCost: kwCost ?? this.kwCost,
      printWeight: printWeight ?? this.printWeight,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      spoolWeight: spoolWeight ?? this.spoolWeight,
      spoolCost: spoolCost ?? this.spoolCost,
      spoolCostText: spoolCostText ?? this.spoolCostText,
      wearAndTear: wearAndTear ?? this.wearAndTear,
      failureRisk: failureRisk ?? this.failureRisk,
      labourRate: labourRate ?? this.labourRate,
      labourTime: labourTime ?? this.labourTime,
      results: results ?? this.results,
      materialUsages: materialUsages ?? this.materialUsages,
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
  ];
}
