import 'package:formz/formz.dart';

// Define input validation errors
enum DoubleInputError { invalid }

// Extend FormzInput and provide the input type and error type.
class DoubleInput extends FormzInput<double?, DoubleInputError> {
  // Call super.pure to represent an unmodified form input.
  const DoubleInput.pure() : super.pure(null);

  // Call super.dirty to represent a modified form input.
  const DoubleInput.dirty({double? value = 0}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  DoubleInputError? validator(double? value) {
    return (value != null && value > -1) ? DoubleInputError.invalid : null;
  }
}
