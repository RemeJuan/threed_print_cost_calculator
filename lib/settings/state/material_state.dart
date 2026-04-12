import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/shared/components/num_input.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';

class MaterialState with FormzMixin {
  final StringInput name;
  final NumberInput cost;
  final StringInput color;
  final NumberInput weight;
  final bool autoDeductEnabled;
  final NumberInput remainingWeight;

  MaterialState({
    this.name = const StringInput.pure(),
    this.cost = const NumberInput.pure(),
    this.color = const StringInput.pure(),
    this.weight = const NumberInput.pure(),
    this.autoDeductEnabled = false,
    this.remainingWeight = const NumberInput.pure(),
  });

  MaterialState copyWith({
    StringInput? name,
    NumberInput? cost,
    StringInput? color,
    NumberInput? weight,
    bool? autoDeductEnabled,
    NumberInput? remainingWeight,
  }) {
    return MaterialState(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      autoDeductEnabled: autoDeductEnabled ?? this.autoDeductEnabled,
      remainingWeight: remainingWeight ?? this.remainingWeight,
    );
  }

  @override
  List<FormzInput> get inputs => [name, cost, color, weight, remainingWeight];
}
