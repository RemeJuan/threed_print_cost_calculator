import 'dart:convert';
import 'dart:typed_data';

import 'gcode_import_result.dart';

class GCodeImportParser {
  const GCodeImportParser();

  static final List<RegExp> _layerHeightPatterns = [
    RegExp(r'^;\s*layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(r'^;\s*Layer height\s*:\s*(.+?)\s*$', caseSensitive: false),
    RegExp(r'^;\s*first_layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
  ];

  static final List<RegExp> _durationPatterns = [
    RegExp(r'^;\s*total estimated time\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(
      r'^;\s*estimated printing time \(normal mode\)\s*=\s*(.+?)\s*$',
      caseSensitive: false,
    ),
    RegExp(r'^;\s*TIME\s*:\s*(.+?)\s*$', caseSensitive: false),
  ];

  static final List<RegExp> _filamentLengthMmPatterns = [
    RegExp(
      r'^;\s*total filament length \[mm\]\s*=\s*(.+?)\s*$',
      caseSensitive: false,
    ),
    RegExp(r'^;\s*filament used \[mm\]\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(r'^;\s*Filament used\s*:\s*(.+?)\s*$', caseSensitive: false),
  ];

  static final List<RegExp> _filamentLengthCmPatterns = [
    RegExp(r'^;\s*filament used \[cm\]\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(
      r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*cm\s*$',
      caseSensitive: false,
    ),
  ];

  static final List<RegExp> _filamentLengthMPatterns = [
    RegExp(r'^;\s*filament used \[m\]\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(
      r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*m\s*$',
      caseSensitive: false,
    ),
  ];

  static final List<RegExp> _filamentWeightPatterns = [
    RegExp(
      r'^;\s*total filament weight \[g\]\s*=\s*(.+?)\s*$',
      caseSensitive: false,
    ),
    RegExp(r'^;\s*filament used \[g\]\s*=\s*(.+?)\s*$', caseSensitive: false),
  ];

  static final _thumbnailBeginRegex = RegExp(
    r'^;\s*(thumbnail(?:_QOI)?)\s+begin\s+(\d+)x(\d+)\s+(\d+)\s*$',
    caseSensitive: false,
  );

  static final _thumbnailEndRegex = RegExp(
    r'^;\s*thumbnail(?:_QOI)?\s+end\s*$',
    caseSensitive: false,
  );

  GCodeImportResult parse(String gcodeText) {
    return parseLines(const LineSplitter().convert(gcodeText));
  }

  GCodeImportResult parseLines(Iterable<String> lines) {
    final state = _StreamingParseState(this);
    for (final line in lines) {
      state.addLine(line);
    }
    return state.build();
  }

  Future<GCodeImportResult> parseLineStream(Stream<String> lines) async {
    final state = _StreamingParseState(this);
    await for (final line in lines) {
      state.addLine(line);
    }
    return state.build();
  }

  GCodeSlicer detectSlicerFromLine(String line) {
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

  Duration? _parseDuration(String? raw) {
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

  double _parseNamedDurationPart(String text, String unit) {
    final match = RegExp(
      '(-?\\d+(?:[\\.,]\\d+)?)\\s*$unit',
      caseSensitive: false,
    ).firstMatch(text);
    return _parseNumber(match?.group(1)) ?? 0;
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

  bool _isPartialMetadata({
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

  void _collectRaw(Map<String, String> raw, String key, String? value) {
    if (value == null || value.trim().isEmpty) return;
    raw[key] = value.trim();
  }
}

class _StreamingParseState {
  _StreamingParseState(this.parser);

  final GCodeImportParser parser;
  final Map<String, String> raw = <String, String>{};

  GCodeSlicer slicer = GCodeSlicer.unknown;
  String? extractedDuration;
  double? layerHeightMm;
  bool mixedMaterials = false;

  double _filamentLengthMmTotal = 0;
  bool _hasFilamentLengthMm = false;
  double _filamentLengthCmTotal = 0;
  bool _hasFilamentLengthCm = false;
  double _filamentLengthMTotal = 0;
  bool _hasFilamentLengthM = false;
  double _filamentWeightGTotal = 0;
  bool _hasFilamentWeightG = false;

  bool inPreview = false;
  StringBuffer currentPreviewBuffer = StringBuffer();
  int? currentPreviewWidth;
  int? currentPreviewHeight;
  String? currentPreviewFormat;
  int? largestSafePreviewArea;
  GCodePreviewMetadata? previewMetadata;
  Uint8List? previewBytes;
  bool hasSafePreview = false;

  void addLine(String line) {
    if (slicer == GCodeSlicer.unknown) {
      final detected = parser.detectSlicerFromLine(line);
      if (detected != GCodeSlicer.unknown) {
        slicer = detected;
      }
    }

    extractedDuration ??= parser.firstMatchingValueInLine(
      line,
      GCodeImportParser._durationPatterns,
    );
    parser._collectRaw(raw, 'estimatedDuration', extractedDuration);

    _collectFirstRaw(
      'filamentLengthMm',
      parser.firstMatchingValueInLine(
        line,
        GCodeImportParser._filamentLengthMmPatterns,
      ),
    );
    _collectFirstRaw(
      'filamentWeightG',
      parser.firstMatchingValueInLine(
        line,
        GCodeImportParser._filamentWeightPatterns,
      ),
    );
    _collectFirstRaw(
      'layerHeightMm',
      parser.firstMatchingValueInLine(
        line,
        GCodeImportParser._layerHeightPatterns,
      ),
    );

    layerHeightMm ??= parser._parseNumber(
      parser.firstMatchingValueInLine(
        line,
        GCodeImportParser._layerHeightPatterns,
      ),
    );

    _addSummedValue(
      line,
      GCodeImportParser._filamentLengthMmPatterns,
      unit: 'mm',
      apply: (value) {
        _filamentLengthMmTotal += value;
        _hasFilamentLengthMm = true;
      },
    );
    _addSummedValue(
      line,
      GCodeImportParser._filamentLengthCmPatterns,
      unit: 'cm',
      apply: (value) {
        _filamentLengthCmTotal += value;
        _hasFilamentLengthCm = true;
      },
    );
    _addSummedValue(
      line,
      GCodeImportParser._filamentLengthMPatterns,
      unit: 'm',
      apply: (value) {
        _filamentLengthMTotal += value;
        _hasFilamentLengthM = true;
      },
    );
    _addSummedValue(
      line,
      GCodeImportParser._filamentWeightPatterns,
      unit: 'g',
      apply: (value) {
        _filamentWeightGTotal += value;
        _hasFilamentWeightG = true;
      },
    );

    if (!mixedMaterials && parser.lineHasMixedOrAmbiguousMaterials(line)) {
      mixedMaterials = true;
    }

    _consumePreviewLine(line);
  }

  GCodeImportResult build() {
    _finishPreviewCandidate();

    final duration = parser._parseDuration(extractedDuration);
    final filamentLengthMm = _hasFilamentLengthMm
        ? _filamentLengthMmTotal
        : _hasFilamentLengthCm
        ? _filamentLengthCmTotal
        : _hasFilamentLengthM
        ? _filamentLengthMTotal
        : null;
    final filamentWeightG = _hasFilamentWeightG ? _filamentWeightGTotal : null;

    final warnings = <GCodeParseWarning>[];
    if (slicer == GCodeSlicer.unknown) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.unknownSlicer),
      );
    }
    if (duration == null) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.missingDuration),
      );
    }
    if (filamentLengthMm == null && filamentWeightG == null) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.missingFilament),
      );
    }
    if (filamentWeightG == null && filamentLengthMm != null) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.missingFilamentWeight),
      );
    }
    if (mixedMaterials) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.mixedMaterials),
      );
    }
    if (parser._isPartialMetadata(
      estimatedDuration: duration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
    )) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.partialMetadata),
      );
    }

    if (previewMetadata != null && previewMetadata!.present) {
      raw['preview'] = previewMetadata!.safeSummary();
    }

    return GCodeImportResult(
      slicer: slicer,
      estimatedDuration: duration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
      previewMetadata: previewMetadata,
      previewImageBytes: previewBytes,
      warnings: List.unmodifiable(warnings),
      rawExtractedValues: Map.unmodifiable(raw),
      hasSafePreview: hasSafePreview,
    );
  }

  void _collectFirstRaw(String key, String? value) {
    if (raw.containsKey(key)) return;
    parser._collectRaw(raw, key, value);
  }

  void _addSummedValue(
    String line,
    List<RegExp> patterns, {
    required String unit,
    required void Function(double value) apply,
  }) {
    final rawValue = parser.firstMatchingValueInLine(line, patterns);
    if (rawValue == null) return;
    final value = parser.sumRawValue(rawValue, unit: unit);
    if (value != null) {
      apply(value);
    }
  }

  void _consumePreviewLine(String line) {
    final beginMatch = GCodeImportParser._thumbnailBeginRegex.firstMatch(line);
    final end = GCodeImportParser._thumbnailEndRegex.hasMatch(line);

    if (beginMatch != null) {
      inPreview = true;
      currentPreviewBuffer = StringBuffer();
      currentPreviewWidth = int.tryParse(beginMatch.group(2) ?? '');
      currentPreviewHeight = int.tryParse(beginMatch.group(3) ?? '');
      currentPreviewFormat =
          (beginMatch.group(1) ?? '').toLowerCase().contains('qoi')
          ? 'QOI'
          : 'PNG';
      return;
    }

    if (end) {
      _finishPreviewCandidate();
      inPreview = false;
      currentPreviewBuffer = StringBuffer();
      currentPreviewWidth = null;
      currentPreviewHeight = null;
      currentPreviewFormat = null;
      return;
    }

    if (!inPreview) return;
    final content = line.startsWith(';') ? line.substring(1).trimLeft() : line;
    if (content.isEmpty) return;
    currentPreviewBuffer.write(content.trim());
  }

  void _finishPreviewCandidate() {
    if (!inPreview ||
        currentPreviewWidth == null ||
        currentPreviewHeight == null ||
        currentPreviewWidth! <= 0 ||
        currentPreviewHeight! <= 0) {
      return;
    }

    final width = currentPreviewWidth!;
    final height = currentPreviewHeight!;
    if (width > 2048 || height > 2048) {
      previewMetadata ??= const GCodePreviewMetadata(
        present: true,
        format: null,
        width: null,
        height: null,
        isSafe: false,
      );
      return;
    }

    final data = currentPreviewBuffer.toString();
    if (data.isEmpty) return;

    Uint8List? decodedBytes;
    try {
      decodedBytes = base64.decode(data);
    } catch (_) {
      return;
    }
    if (decodedBytes.isEmpty) return;

    final area = width * height;
    if (largestSafePreviewArea == null || area > largestSafePreviewArea!) {
      largestSafePreviewArea = area;
      previewMetadata = GCodePreviewMetadata(
        present: true,
        format: currentPreviewFormat ?? 'PNG',
        width: width,
        height: height,
        isSafe: true,
      );
      previewBytes = decodedBytes;
      hasSafePreview = true;
    }
  }
}
