import 'package:formz/formz.dart';

// Define input validation errors
enum StringInputError { empty }

// Extend FormzInput and provide the input type and error type.
class StringInput extends FormzInput<String, StringInputError> {
  // Call super.pure to represent an unmodified form input.
  const StringInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const StringInput.dirty({String value = ''}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  StringInputError? validator(String value) {
    return value.isEmpty ? StringInputError.empty : null;
  }
}
