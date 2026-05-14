library;

String formatPercent(num? value) {
  final percent = value ?? 0;
  final text = percent.toStringAsFixed(
    percent.truncateToDouble() == percent ? 0 : 2,
  );
  return text
      .replaceFirst(RegExp(r'\.0+$'), '')
      .replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
}

String formatCurrencyValue(
  num value, {
  required String currencySymbol,
  required String currencyPosition,
  required bool currencySpacing,
}) {
  final amount = value.toStringAsFixed(2);
  if (currencySymbol.isEmpty) return amount;
  final separator = currencySpacing ? ' ' : '';
  return currencyPosition == 'after'
      ? '$amount$separator$currencySymbol'
      : '$currencySymbol$separator$amount';
}
