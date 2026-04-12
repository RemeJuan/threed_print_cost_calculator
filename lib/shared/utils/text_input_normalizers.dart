String normalizeLeadingZeroNumericInput(
  String text, {
  bool allowDecimal = true,
}) {
  if (text.isEmpty) return text;

  if (allowDecimal) {
    final separatorIndex = text.indexOf(RegExp(r'[\.,]'));
    if (separatorIndex != -1) {
      final wholePart = text.substring(0, separatorIndex);
      final fractionalPart = text.substring(separatorIndex);
      final normalizedWholePart = _normalizeIntegerPart(wholePart);
      return '$normalizedWholePart$fractionalPart';
    }
  }

  return _normalizeIntegerPart(text);
}

String _normalizeIntegerPart(String text) {
  if (text.isEmpty) return '0';
  if (text.length <= 1 || !RegExp(r'^0+\d+$').hasMatch(text)) {
    return text;
  }

  final normalized = text.replaceFirst(RegExp(r'^0+'), '');
  return normalized.isEmpty ? '0' : normalized;
}
