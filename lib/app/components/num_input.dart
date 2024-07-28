import 'package:formz/formz.dart';

// Define input validation errors
enum NumberInputError { invalid }

// Extend FormzInput and provide the input type and error type.
class NumberInput extends FormzInput<num?, NumberInputError> {
  // Call super.pure to represent an unmodified form input.
  const NumberInput.pure() : super.pure(null);

  // Call super.dirty to represent a modified form input.
  const NumberInput.dirty({num? value = 0}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  NumberInputError? validator(num? value) {
    return (value != null && value > -1) ? NumberInputError.invalid : null;
  }
}
