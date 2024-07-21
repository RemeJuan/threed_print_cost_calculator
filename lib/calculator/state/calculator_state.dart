import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/app/components/double_input.dart';
import 'package:threed_print_cost_calculator/app/components/int_input.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';

class CalculatorState with FormzMixin {
  final IntInput watt;
  final IntInput kwCost;
  final IntInput printWeight;
  final IntInput hours;
  final IntInput minutes;
  final IntInput spoolWeight;
  final IntInput spoolCost;
  final DoubleInput wearAndTear;
  final DoubleInput failureRisk;
  final DoubleInput labourRate;
  final DoubleInput labourTime;
  final CalculationResult results;

  CalculatorState({
    this.watt = const IntInput.pure(),
    this.kwCost = const IntInput.pure(),
    this.printWeight = const IntInput.pure(),
    this.hours = const IntInput.pure(),
    this.minutes = const IntInput.pure(),
    this.spoolWeight = const IntInput.pure(),
    this.spoolCost = const IntInput.pure(),
    this.wearAndTear = const DoubleInput.pure(),
    this.failureRisk = const DoubleInput.pure(),
    this.labourRate = const DoubleInput.pure(),
    this.labourTime = const DoubleInput.pure(),
    this.results = const CalculationResult(
      electricity: 0.0,
      filament: 0.0,
      risk: 0.0,
      labour: 0.0,
      total: 0.0,
    ),
  });

  CalculatorState copyWith({
    IntInput? watt,
    IntInput? kwCost,
    IntInput? printWeight,
    IntInput? hours,
    IntInput? minutes,
    IntInput? spoolWeight,
    IntInput? spoolCost,
    DoubleInput? wearAndTear,
    DoubleInput? failureRisk,
    DoubleInput? labourRate,
    DoubleInput? labourTime,
    CalculationResult? results,
  }) {
    return CalculatorState(
      watt: watt ?? this.watt,
      kwCost: kwCost ?? this.kwCost,
      printWeight: printWeight ?? this.printWeight,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      spoolWeight: spoolWeight ?? this.spoolWeight,
      spoolCost: spoolCost ?? this.spoolCost,
      wearAndTear: wearAndTear ?? this.wearAndTear,
      failureRisk: failureRisk ?? this.failureRisk,
      labourRate: labourRate ?? this.labourRate,
      labourTime: labourTime ?? this.labourTime,
      results: results ?? this.results,
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
