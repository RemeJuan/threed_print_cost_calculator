import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/app/components/double_input.dart';
import 'package:threed_print_cost_calculator/app/components/int_input.dart';
import 'package:threed_print_cost_calculator/app/components/string_input.dart';

class MaterialState with FormzMixin {
  final StringInput name;
  final DoubleInput cost;
  final StringInput color;
  final IntInput weight;

  MaterialState({
    this.name = const StringInput.pure(),
    this.cost = const DoubleInput.pure(),
    this.color = const StringInput.pure(),
    this.weight = const IntInput.pure(),
  });

  MaterialState copyWith({
    StringInput? name,
    DoubleInput? cost,
    StringInput? color,
    IntInput? weight,
  }) {
    return MaterialState(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      color: color ?? this.color,
      weight: weight ?? this.weight,
    );
  }

  @override
  List<FormzInput> get inputs => [name, cost, color, weight];
}
