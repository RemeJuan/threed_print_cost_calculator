library;

String normalizeLocalizedNumber(Object? input) {
  return input?.toString().trim().replaceAll(',', '.') ?? '';
}

double? parseLocalizedNum(String input) {
  final normalized = normalizeLocalizedNumber(input);
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

double? tryParseLocalizedNum(Object? input) {
  final normalized = normalizeLocalizedNumber(input);
  if (normalized.isEmpty) return null;
  return parseLocalizedNum(normalized);
}

double parseLocalizedNumOrFallback(Object? input, {double fallback = 0}) {
  return tryParseLocalizedNum(input) ?? fallback;
}

int? tryParseLocalizedInt(Object? input, {bool round = false}) {
  final parsed = tryParseLocalizedNum(input);
  if (parsed == null) return null;
  return round ? parsed.round() : parsed.toInt();
}

int parseLocalizedInt(Object? input, {int fallback = 0, bool round = false}) {
  return tryParseLocalizedInt(input, round: round) ?? fallback;
}
