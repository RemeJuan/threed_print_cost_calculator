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
  final StringInput brand;
  final StringInput materialType;
  final StringInput colorHex;
  final StringInput notes;

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
    this.brand = const StringInput.pure(),
    this.materialType = const StringInput.pure(),
    this.colorHex = const StringInput.pure(),
    this.notes = const StringInput.pure(),
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
    StringInput? brand,
    StringInput? materialType,
    StringInput? colorHex,
    StringInput? notes,
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
      brand: brand ?? this.brand,
      materialType: materialType ?? this.materialType,
      colorHex: colorHex ?? this.colorHex,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<FormzInput> get inputs => [name, cost, color, weight, remainingWeight];
}
