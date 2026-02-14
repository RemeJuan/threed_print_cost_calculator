import 'package:formz/formz.dart';
import 'package:threed_print_cost_calculator/shared/components/string_input.dart';

class PrinterState with FormzMixin {
  final StringInput name;
  final StringInput bedSize;
  final StringInput wattage;

  PrinterState({
    this.name = const StringInput.pure(),
    this.bedSize = const StringInput.pure(),
    this.wattage = const StringInput.pure(),
  });

  PrinterState copyWith({
    StringInput? name,
    StringInput? bedSize,
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
