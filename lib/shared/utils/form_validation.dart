import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

enum FieldValidationError {
  required,
  invalidNumber,
  greaterThanZero,
  atLeastZero,
}

FieldValidationError? validateRequiredText(String? value) {
  if ((value ?? '').trim().isEmpty) {
    return FieldValidationError.required;
  }

  return null;
}

FieldValidationError? validatePositiveNumber(String? value) {
  final rawValue = value ?? '';
  if (rawValue.trim().isEmpty) {
    return FieldValidationError.required;
  }

  final parsedValue = parseLocalizedNum(rawValue);
  if (parsedValue == null) {
    return FieldValidationError.invalidNumber;
  }

  if (parsedValue <= 0) {
    return FieldValidationError.greaterThanZero;
  }

  return null;
}

FieldValidationError? validatePrinterBedSize(String? value) {
  final rawValue = value ?? '';
  if (rawValue.trim().isEmpty) {
    return FieldValidationError.required;
  }

  final numericValidation = validatePositiveNumber(rawValue);
  if (numericValidation == null ||
      numericValidation == FieldValidationError.greaterThanZero) {
    return numericValidation;
  }

  final parts = rawValue.trim().split(RegExp(r'\s*[xX]\s*'));
  if (parts.length < 2) {
    return FieldValidationError.invalidNumber;
  }

  for (final part in parts) {
    final parsedValue = parseLocalizedNum(part);
    if (parsedValue == null) {
      return FieldValidationError.invalidNumber;
    }

    if (parsedValue <= 0) {
      return FieldValidationError.greaterThanZero;
    }
  }

  return null;
}

FieldValidationError? validateOptionalNonNegativeNumber(String? value) {
  final rawValue = value ?? '';
  if (rawValue.trim().isEmpty) {
    return null;
  }

  final parsedValue = parseLocalizedNum(rawValue);
  if (parsedValue == null) {
    return FieldValidationError.invalidNumber;
  }

  if (parsedValue < 0) {
    return FieldValidationError.atLeastZero;
  }

  return null;
}

String? localizedValidationMessage(
  AppLocalizations l10n,
  FieldValidationError? error,
) {
  return switch (error) {
    FieldValidationError.required => l10n.validationRequired,
    FieldValidationError.invalidNumber => l10n.validationEnterValidNumber,
    FieldValidationError.greaterThanZero =>
      l10n.validationMustBeGreaterThanZero,
    FieldValidationError.atLeastZero => l10n.validationMustBeZeroOrMore,
    null => null,
  };
}
