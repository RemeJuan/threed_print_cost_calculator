/// Shared weight formatting utility.
///
/// Formats a numeric weight value with zero or one decimal place,
/// suppressing the decimal point when the value is a whole number.
String formatWeight(num value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
