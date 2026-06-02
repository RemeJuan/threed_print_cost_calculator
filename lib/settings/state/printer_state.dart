import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';

class PrinterState with FormzMixin {
  final StringInput name;
  final StringInput bedSize;
  final StringInput wattage;
  final StringInput averageWattage;

  PrinterState({
    this.name = const StringInput.pure(),
    this.bedSize = const StringInput.pure(),
    this.wattage = const StringInput.pure(),
    this.averageWattage = const StringInput.pure(),
  });

  PrinterState copyWith({
    StringInput? name,
    StringInput? bedSize,
    StringInput? wattage,
    StringInput? averageWattage,
  }) {
    return PrinterState(
      name: name ?? this.name,
      bedSize: bedSize ?? this.bedSize,
      wattage: wattage ?? this.wattage,
      averageWattage: averageWattage ?? this.averageWattage,
    );
  }

  @override
  List<FormzInput> get inputs => [name, bedSize, wattage, averageWattage];
}
