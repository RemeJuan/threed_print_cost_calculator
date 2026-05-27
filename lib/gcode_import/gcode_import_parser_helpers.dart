part of 'gcode_import_parser.dart';

GCodeSlicer _detectSlicerFromLine(String line) {
  final lower = line.toLowerCase();
  if (lower.contains('prusaslicer')) {
    return GCodeSlicer.prusaSlicer;
  }
  if (lower.contains('orcaslicer')) {
    return GCodeSlicer.orcaSlicer;
  }
  if (lower.contains('bambustudio') || lower.contains('bambu studio')) {
    return GCodeSlicer.bambuStudio;
  }
  if (lower.contains('cura_steamengine') ||
      lower.contains('generated with cura')) {
    return GCodeSlicer.cura;
  }
  return GCodeSlicer.unknown;
}

Duration? parseDuration(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final lower = raw.toLowerCase();
  try {
    if (RegExp(r'[dhms]').hasMatch(lower)) {
      final d = _parseNamedDurationPart(lower, 'd');
      final h = _parseNamedDurationPart(lower, 'h');
      final m = _parseNamedDurationPart(lower, 'm');
      final s = _parseNamedDurationPart(lower, 's');
      final seconds = (d * 86400 + h * 3600 + m * 60 + s).round();
      return seconds > 0 ? Duration(seconds: seconds) : null;
    }
    final seconds = _parseNumber(raw);
    return seconds == null ? null : Duration(seconds: seconds.round());
  } catch (_) {
    return null;
  }
}

String? firstMatchingValueInLine(String line, List<RegExp> expressions) {
  for (final expression in expressions) {
    final match = expression.firstMatch(line);
    if (match != null) return match.group(1)?.trim();
  }
  return null;
}

double? sumRawValue(String raw, {required String unit}) {
  final targetUnit = unit == 'g' ? 'g' : 'mm';
  final values = <double>[];
  final singleValue = RegExp(r'^-?\d+(?:[\.,]\d+)?$').firstMatch(raw.trim());
  if (singleValue != null) {
    final value = _parseNumber(singleValue.group(0));
    if (value != null) {
      values.add(_normalizeValue(value, unit, targetUnit));
    }
  } else {
    values.addAll(_parseUnitList(raw, targetUnit));
  }

  if (values.isEmpty) return null;
  return values.fold<double>(0, (sum, value) => sum + value);
}

bool lineHasMixedOrAmbiguousMaterials(String line) {
  final lower = line.toLowerCase();
  for (final key in const [
    'filament used [mm]',
    'filament used [g]',
    'extruder',
    'toolchange',
    't0',
    't1',
    'multi-extruder',
  ]) {
    if (!lower.contains(key)) continue;

    final keyIndex = lower.indexOf(key);
    var value = lower.substring(keyIndex + key.length).trim();
    if (value.startsWith(':')) {
      value = value.substring(1).trim();
    }

    if (value.contains(',')) return true;
    if (key == 'toolchange' || key == 'multi-extruder') return true;

    final extruderTokens = RegExp(
      r'\b(?:t0|t1|extruder\s*\d+)\b',
    ).allMatches(lower).length;
    if (extruderTokens > 1) return true;

    if (key == 'extruder' &&
        RegExp(r'\bextruder\s*[1-9]\d*\b').hasMatch(lower)) {
      return true;
    }
  }
  return false;
}

bool isPartialMetadata({
  required Duration? estimatedDuration,
  required double? filamentLengthMm,
  required double? filamentWeightG,
  required double? layerHeightMm,
}) {
  final found = [
    estimatedDuration,
    filamentLengthMm,
    filamentWeightG,
    layerHeightMm,
  ].where((value) => value != null).length;
  return found > 0 && found < 4;
}

double _parseNamedDurationPart(String text, String unit) {
  final match = RegExp(
    '(-?\\d+(?:[\\.,]\\d+)?)\\s*$unit',
    caseSensitive: false,
  ).firstMatch(text);
  return _parseNumber(match?.group(1)) ?? 0;
}

List<double> _parseUnitList(String raw, String unit) {
  final text = raw.toLowerCase();
  final matches = RegExp(
    r'(-?\d+(?:[\.,]\d+)?)\s*(mm|cm|m|g|kg)?',
  ).allMatches(text);
  final out = <double>[];
  for (final match in matches) {
    final value = _parseNumber(match.group(1));
    if (value == null) continue;
    final foundUnit = match.group(2);
    out.add(_normalizeValue(value, foundUnit, unit));
  }
  return out;
}

double _normalizeValue(double value, String? foundUnit, String unit) {
  switch (unit) {
    case 'mm':
      switch (foundUnit) {
        case 'm':
          return value * 1000;
        case 'cm':
          return value * 10;
        default:
          return value;
      }
    case 'g':
      switch (foundUnit) {
        case 'kg':
          return value * 1000;
        default:
          return value;
      }
    default:
      return value;
  }
}

double? _parseNumber(String? rawValue) {
  if (rawValue == null || rawValue.trim().isEmpty) return null;
  final match = RegExp(r'(-?\d+(?:[\.,]\d+)?)').firstMatch(rawValue);
  if (match == null) return null;
  return double.tryParse(match.group(1)!.replaceAll(',', '.'));
}
