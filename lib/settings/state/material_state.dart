import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';

class MaterialState with FormzMixin {
  final StringInput name;
  final NumberInput cost;
  final String costText;
  final StringInput color;
  final NumberInput weight;
  final String weightText;
  final bool autoDeductEnabled;
  final NumberInput remainingWeight;
  final String remainingWeightText;

  MaterialState({
    this.name = const StringInput.pure(),
    this.cost = const NumberInput.pure(),
    this.costText = '',
    this.color = const StringInput.pure(),
    this.weight = const NumberInput.pure(),
    this.weightText = '',
    this.autoDeductEnabled = false,
    this.remainingWeight = const NumberInput.pure(),
    this.remainingWeightText = '',
  });

  MaterialState copyWith({
    StringInput? name,
    NumberInput? cost,
    String? costText,
    StringInput? color,
    NumberInput? weight,
    String? weightText,
    bool? autoDeductEnabled,
    NumberInput? remainingWeight,
    String? remainingWeightText,
  }) {
    return MaterialState(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      costText: costText ?? this.costText,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      weightText: weightText ?? this.weightText,
      autoDeductEnabled: autoDeductEnabled ?? this.autoDeductEnabled,
      remainingWeight: remainingWeight ?? this.remainingWeight,
      remainingWeightText: remainingWeightText ?? this.remainingWeightText,
    );
  }

  @override
  List<FormzInput> get inputs => [name, cost, color, weight, remainingWeight];
}
