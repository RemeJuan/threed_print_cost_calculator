import 'package:formz/formz.dart';

// Define input validation errors
enum IntInputError { invalid }

// Extend FormzInput and provide the input type and error type.
class IntInput extends FormzInput<int, IntInputError> {
  // Call super.pure to represent an unmodified form input.
  const IntInput.pure() : super.pure(-1);

  // Call super.dirty to represent a modified form input.
  const IntInput.dirty({int value = 0}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  IntInputError? validator(int value) {
    return value > -1 ? IntInputError.invalid : null;
  }
}
