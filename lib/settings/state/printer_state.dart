import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/app/components/double_input.dart';
import 'package:threed_print_cost_calculator/app/components/string_input.dart';

class PrinterState with FormzMixin {
  final StringInput name;
  final DoubleInput bedSize;
  final StringInput wattage;

  PrinterState({
    this.name = const StringInput.pure(),
    this.bedSize = const DoubleInput.pure(),
    this.wattage = const StringInput.pure(),
  });

  PrinterState copyWith({
    StringInput? name,
    DoubleInput? bedSize,
    StringInput? wattage,
  }) {
    return PrinterState(
      name: name ?? this.name,
      bedSize: bedSize ?? this.bedSize,
      wattage: wattage ?? this.wattage,
    );
  }

  @override
  List<FormzInput> get inputs => [name, bedSize, wattage];
}
