import 'dart:convert';
import 'dart:typed_data';

import 'gcode_import_result.dart';

class GCodeImportParser {
  const GCodeImportParser();

  static final _thumbnailBeginRegex = RegExp(
    r'^;\s*(thumbnail(?:_QOI)?)\s+begin\s+(\d+)x(\d+)\s+(\d+)\s*$',
    caseSensitive: false,
  );

  static final _thumbnailEndRegex = RegExp(
    r'^;\s*thumbnail(?:_QOI)?\s+end\s*$',
    caseSensitive: false,
  );

  GCodeImportResult parse(String gcodeText) {
    final lines = const LineSplitter().convert(gcodeText);
    final slicer = _detectSlicer(lines);
    final warnings = <GCodeParseWarning>[];
    final raw = <String, String>{};

    final duration = _parseDuration(_extractDuration(lines));
    final filamentLengthMm = _parseFilamentLengthMm(lines);
    final filamentWeightG = _parseFilamentWeightG(lines);
    final layerHeightMm = _parseNumber(
      _firstMatchingValue(lines, [
        RegExp(r'^;\s*layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
        RegExp(r'^;\s*Layer height\s*:\s*(.+?)\s*$', caseSensitive: false),
        RegExp(
          r'^;\s*first_layer_height\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
      ]),
    );

    // Parse preview metadata candidates and image bytes together,
    // ensuring we only mark as safe if bytes decode successfully
    final previewResult = _parsePreviewWithValidation(lines);
    final previewMetadata = previewResult.metadata;
    final previewImageBytes = previewResult.bytes;

    _collectRaw(raw, 'estimatedDuration', _extractDuration(lines));
    _collectRaw(raw, 'filamentLengthMm', _extractFilamentLengthRaw(lines));
    _collectRaw(raw, 'filamentWeightG', _extractFilamentWeightRaw(lines));
    _collectRaw(
      raw,
      'layerHeightMm',
      _firstMatchingValue(lines, [
        RegExp(r'^;\s*layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
        RegExp(r'^;\s*Layer height\s*:\s*(.+?)\s*$', caseSensitive: false),
        RegExp(
          r'^;\s*first_layer_height\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
      ]),
    );

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

    if (_hasMixedOrAmbiguousMaterials(lines)) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.mixedMaterials),
      );
    }
    if (_isPartialMetadata(
      estimatedDuration: duration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
    )) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.partialMetadata),
      );
    }

    if (previewMetadata != null && previewMetadata.present) {
      raw['preview'] = previewMetadata.safeSummary;
    }

    return GCodeImportResult(
      slicer: slicer,
      estimatedDuration: duration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
      previewMetadata: previewMetadata,
      previewImageBytes: previewImageBytes,
      warnings: List.unmodifiable(warnings),
      rawExtractedValues: Map.unmodifiable(raw),
      hasSafePreview: previewResult.hasSafePreview,
    );
  }

  GCodeSlicer _detectSlicer(List<String> lines) {
    final lower = lines.map((l) => l.toLowerCase()).toList();
    if (lower.any((l) => l.contains('prusaslicer'))) {
      return GCodeSlicer.prusaSlicer;
    }
    if (lower.any((l) => l.contains('orcaslicer'))) {
      return GCodeSlicer.orcaSlicer;
    }
    if (lower.any(
      (l) => l.contains('bambustudio') || l.contains('bambu studio'),
    )) {
      return GCodeSlicer.bambuStudio;
    }
    if (lower.any(
      (l) =>
          l.contains('cura_steamengine') || l.contains('generated with cura'),
    )) {
      return GCodeSlicer.cura;
    }
    return GCodeSlicer.unknown;
  }

  _PreviewParseResult _parsePreviewWithValidation(List<String> lines) {
    // First, collect all preview candidates
    final candidates = <_PreviewCandidate>[];

    var inPreview = false;
    var currentBuffer = StringBuffer();
    int? currentWidth;
    int? currentHeight;
    String? currentFormat;

    for (final line in lines) {
      final beginMatch = _thumbnailBeginRegex.firstMatch(line);
      final end = _thumbnailEndRegex.hasMatch(line);

      if (beginMatch != null) {
        inPreview = true;
        currentBuffer = StringBuffer();
        currentWidth = int.tryParse(beginMatch.group(2) ?? '');
        currentHeight = int.tryParse(beginMatch.group(3) ?? '');
        currentFormat = (beginMatch.group(1) ?? '').toLowerCase().contains('qoi')
            ? 'QOI'
            : 'PNG';
        continue;
      }

      if (end) {
        if (inPreview &&
            currentWidth != null &&
            currentHeight != null &&
            currentWidth > 0 &&
            currentHeight > 0) {
          candidates.add(_PreviewCandidate(
            width: currentWidth,
            height: currentHeight,
            format: currentFormat ?? 'PNG',
            base64Data: currentBuffer.toString(),
          ));
        }
        inPreview = false;
        currentBuffer = StringBuffer();
        currentWidth = null;
        currentHeight = null;
        currentFormat = null;
        continue;
      }

      if (!inPreview) continue;
      final content = line.startsWith(';')
          ? line.substring(1).trimLeft()
          : line;
      if (content.isEmpty) continue;
      currentBuffer.write(content.trim());
    }

    // Now find the largest safe preview that actually decodes
    int? largestSafeArea;
    GCodePreviewMetadata? winningMetadata;
    Uint8List? winningBytes;
    bool hasSafe = false;

    for (final candidate in candidates) {
      final area = candidate.width * candidate.height;

      // Check if dimensions are safe
      if (candidate.width > 2048 || candidate.height > 2048) {
        // Mark that we found a preview, but it's not safe
        if (winningMetadata == null) {
          winningMetadata = const GCodePreviewMetadata(
            present: true,
            format: null,
            width: null,
            height: null,
            isSafe: false,
          );
        }
        continue;
      }

      // Try to decode the base64 data
      Uint8List? bytes;
      try {
        if (candidate.base64Data.isNotEmpty) {
          bytes = base64.decode(candidate.base64Data);
        }
      } catch (_) {
        // Decoding failed, skip this candidate
        continue;
      }

      if (bytes == null || bytes.isEmpty) continue;

      // This candidate is safe and decoded successfully
      if (largestSafeArea == null || area > largestSafeArea) {
        largestSafeArea = area;
        winningMetadata = GCodePreviewMetadata(
          present: true,
          format: candidate.format,
          width: candidate.width,
          height: candidate.height,
          isSafe: true,
        );
        winningBytes = bytes;
        hasSafe = true;
      }
    }

    return _PreviewParseResult(
      metadata: winningMetadata,
      bytes: winningBytes,
      hasSafePreview: hasSafe,
    );
  }

  String? _extractDuration(List<String> lines) => _firstMatchingValue(lines, [
    RegExp(r'^;\s*total estimated time\s*=\s*(.+?)\s*$', caseSensitive: false),
    RegExp(
      r'^;\s*estimated printing time \(normal mode\)\s*=\s*(.+?)\s*$',
      caseSensitive: false,
    ),
    RegExp(r'^;\s*TIME\s*:\s*(.+?)\s*$', caseSensitive: false),
  ]);

  String? _extractFilamentLengthRaw(List<String> lines) =>
      _firstMatchingValue(lines, [
        RegExp(
          r'^;\s*total filament length \[mm\]\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
        RegExp(
          r'^;\s*filament used \[mm\]\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
        RegExp(r'^;\s*Filament used\s*:\s*(.+?)\s*$', caseSensitive: false),
      ]);

  String? _extractFilamentWeightRaw(List<String> lines) =>
      _firstMatchingValue(lines, [
        RegExp(
          r'^;\s*total filament weight \[g\]\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
        RegExp(
          r'^;\s*filament used \[g\]\s*=\s*(.+?)\s*$',
          caseSensitive: false,
        ),
      ]);

  String? _firstMatchingValue(List<String> lines, List<RegExp> expressions) {
    for (final line in lines) {
      for (final expression in expressions) {
        final match = expression.firstMatch(line);
        if (match != null) return match.group(1)?.trim();
      }
    }
    return null;
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

  double? _parseFilamentLengthMm(List<String> lines) {
    final explicit = _sumValues(lines, [
      RegExp(
        r'^;\s*total filament length \[mm\]\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(
        r'^;\s*filament used \[mm\]\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(r'^;\s*Filament used\s*:\s*(.+?)\s*$', caseSensitive: false),
    ], unit: 'mm');
    if (explicit != null) return explicit;

    final cm = _sumValues(lines, [
      RegExp(
        r'^;\s*filament used \[cm\]\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(
        r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*cm\s*$',
        caseSensitive: false,
      ),
    ], unit: 'cm');
    if (cm != null) return cm;

    final m = _sumValues(lines, [
      RegExp(r'^;\s*filament used \[m\]\s*=\s*(.+?)\s*$', caseSensitive: false),
      RegExp(
        r'^;\s*filament\s+(?:used|length)\s*[=:]\s*(.+?)\s*m\s*$',
        caseSensitive: false,
      ),
    ], unit: 'm');
    if (m != null) return m;

    return null;
  }

  double? _parseFilamentWeightG(List<String> lines) {
    return _sumValues(lines, [
      RegExp(
        r'^;\s*total filament weight \[g\]\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(r'^;\s*filament used \[g\]\s*=\s*(.+?)\s*$', caseSensitive: false),
    ], unit: 'g');
  }

  double? _sumValues(
    List<String> lines,
    List<RegExp> patterns, {
    required String unit,
  }) {
    final targetUnit = unit == 'g' ? 'g' : 'mm';
    final values = <double>[];
    for (final line in lines) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(line);
        if (match == null) continue;
        final raw = match.group(1) ?? '';
        final singleValue = RegExp(
          r'^-?\d+(?:[\.,]\d+)?$',
        ).firstMatch(raw.trim());
        if (singleValue != null) {
          final value = _parseNumber(singleValue.group(0));
          if (value != null) {
            values.add(_normalizeValue(value, unit, targetUnit));
            break;
          }
        }
        values.addAll(_parseUnitList(raw, targetUnit));
        break;
      }
    }
    if (values.isEmpty) return null;
    return values.fold<double>(0, (sum, value) => sum + value);
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

  bool _hasMixedOrAmbiguousMaterials(List<String> lines) {
    const key = 'filament used [mm]';
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (!lower.contains(key)) continue;

      final keyIndex = lower.indexOf(key);
      var value = line.substring(keyIndex + key.length).trim();
      if (value.startsWith(':')) {
        value = value.substring(1).trim();
      }

      if (value.contains(',')) return true;
    }
    return false;
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

class _PreviewCandidate {
  const _PreviewCandidate({
    required this.width,
    required this.height,
    required this.format,
    required this.base64Data,
  });

  final int width;
  final int height;
  final String format;
  final String base64Data;
}

class _PreviewParseResult {
  const _PreviewParseResult({
    required this.metadata,
    required this.bytes,
    required this.hasSafePreview,
  });

  final GCodePreviewMetadata? metadata;
  final Uint8List? bytes;
  final bool hasSafePreview;
}
