library;

String normalizeLocalizedNumber(Object? input) {
  return input?.toString().trim().replaceAll(',', '.') ?? '';
}

num? tryParseLocalizedNum(Object? input) {
  final normalized = normalizeLocalizedNumber(input);
  if (normalized.isEmpty) return null;
  return num.tryParse(normalized);
}

num parseLocalizedNum(Object? input, {num fallback = 0}) {
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
