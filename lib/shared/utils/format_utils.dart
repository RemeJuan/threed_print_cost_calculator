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
