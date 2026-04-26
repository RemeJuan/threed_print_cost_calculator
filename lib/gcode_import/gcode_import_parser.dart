import 'dart:convert';

import 'gcode_import_result.dart';

class GCodeImportParser {
  const GCodeImportParser();

  GCodeImportResult parse(String gcodeText) {
    final lines = const LineSplitter().convert(gcodeText);
    final slicer = _detectSlicer(lines);
    final raw = <String, String>{};

    final estimatedDurationRaw = _firstMatchingValue(lines, [
      RegExp(
        r'^;\s*total estimated time\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(
        r'^;\s*estimated printing time \(normal mode\)\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(r'^;\s*TIME\s*:\s*(.+?)\s*$', caseSensitive: false),
    ]);
    final filamentLengthMmRaw = _firstMatchingValue(lines, [
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
    final filamentWeightGRaw = _firstMatchingValue(lines, [
      RegExp(
        r'^;\s*total filament weight \[g\]\s*=\s*(.+?)\s*$',
        caseSensitive: false,
      ),
      RegExp(r'^;\s*filament used \[g\]\s*=\s*(.+?)\s*$', caseSensitive: false),
    ]);
    final layerHeightRaw = _firstMatchingValue(lines, [
      RegExp(r'^;\s*layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
      RegExp(r'^;\s*Layer height\s*:\s*(.+?)\s*$', caseSensitive: false),
      RegExp(r'^;\s*first_layer_height\s*=\s*(.+?)\s*$', caseSensitive: false),
    ]);
    final previewMetadata = _parsePreviewMetadata(lines);

    final estimatedDuration = _parseDuration(estimatedDurationRaw);
    final filamentLengthMm = _parseFilamentLengthMm(filamentLengthMmRaw);
    final filamentWeightG = _parseNumber(filamentWeightGRaw);
    final layerHeightMm = _parseNumber(layerHeightRaw);

    _collectRaw(raw, 'estimatedDuration', estimatedDurationRaw);
    _collectRaw(raw, 'filamentLengthMm', filamentLengthMmRaw);
    _collectRaw(raw, 'filamentWeightG', filamentWeightGRaw);
    _collectRaw(raw, 'layerHeightMm', layerHeightRaw);
    if (previewMetadata != null && previewMetadata.present) {
      raw['preview'] = [
        previewMetadata.format,
        previewMetadata.width == null || previewMetadata.height == null
            ? null
            : '${previewMetadata.width}x${previewMetadata.height}',
      ].whereType<String>().join(' ');
    }

    final warnings = <GCodeParseWarning>[];
    if (slicer == GCodeSlicer.unknown) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.unknownSlicer),
      );
    }
    if (estimatedDuration == null) {
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
    if (_isPartialMetadata(
      estimatedDuration: estimatedDuration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
    )) {
      warnings.add(
        const GCodeParseWarning(GCodeParseWarningCode.partialMetadata),
      );
    }

    return GCodeImportResult(
      slicer: slicer,
      estimatedDuration: estimatedDuration,
      filamentLengthMm: filamentLengthMm,
      filamentWeightG: filamentWeightG,
      layerHeightMm: layerHeightMm,
      previewMetadata: previewMetadata,
      warnings: List.unmodifiable(warnings),
      rawExtractedValues: Map.unmodifiable(raw),
    );
  }

  GCodeSlicer _detectSlicer(List<String> lines) {
    final lowerLines = lines.map((line) => line.toLowerCase()).toList();
    final hasPrusa = lowerLines.any((line) => line.contains('prusaslicer'));
    final hasOrca = lowerLines.any((line) => line.contains('orcaslicer'));
    final hasBambu = lowerLines.any(
      (line) => line.contains('bambustudio') || line.contains('bambu studio'),
    );
    final hasCura = lowerLines.any(
      (line) =>
          line.contains('cura_steamengine') ||
          line.contains('generated with cura'),
    );

    if (hasPrusa) return GCodeSlicer.prusaSlicer;
    if (hasOrca) return GCodeSlicer.orcaSlicer;
    if (hasBambu) {
      final hasBambuTotalKeys = lowerLines.any(
        (line) =>
            line.contains('total estimated time') ||
            line.contains('total filament length [mm]') ||
            line.contains('total filament weight [g]'),
      );
      final hasOrcaStyleKeys = lowerLines.any(
        (line) =>
            line.contains('estimated printing time (normal mode)') ||
            line.startsWith(';time:') ||
            line.contains('filament used [mm]') ||
            line.contains('filament used:'),
      );
      if (!hasBambuTotalKeys && hasOrcaStyleKeys) {
        return GCodeSlicer.orcaSlicer;
      }
      return GCodeSlicer.bambuStudio;
    }
    if (hasCura) return GCodeSlicer.cura;
    return GCodeSlicer.unknown;
  }

  GCodePreviewMetadata? _parsePreviewMetadata(List<String> lines) {
    for (final line in lines) {
      final match = RegExp(
        r'^;\s*(thumbnail(?:_QOI)?)\s+begin\s+(\d+)x(\d+)\s+\d+',
        caseSensitive: false,
      ).firstMatch(line);
      if (match == null) continue;

      final marker = (match.group(1) ?? '').toLowerCase();
      return GCodePreviewMetadata(
        present: true,
        format: marker.contains('qoi') ? 'QOI' : 'PNG',
        width: int.tryParse(match.group(2) ?? ''),
        height: int.tryParse(match.group(3) ?? ''),
      );
    }

    return null;
  }

  String? _firstMatchingValue(List<String> lines, List<RegExp> expressions) {
    for (final line in lines) {
      for (final expression in expressions) {
        final match = expression.firstMatch(line);
        if (match != null) return match.group(1)?.trim();
      }
    }
    return null;
  }

  Duration? _parseDuration(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;

    final lower = rawValue.toLowerCase();
    if (RegExp(r'[dhms]').hasMatch(lower)) {
      final days = _parseNamedDurationPart(lower, 'd');
      final hours = _parseNamedDurationPart(lower, 'h');
      final minutes = _parseNamedDurationPart(lower, 'm');
      final seconds = _parseNamedDurationPart(lower, 's');
      final totalSeconds =
          (days * 86400 + hours * 3600 + minutes * 60 + seconds).round();
      return totalSeconds <= 0 ? null : Duration(seconds: totalSeconds);
    }

    final seconds = _parseNumber(rawValue);
    if (seconds == null) return null;
    return Duration(seconds: seconds.round());
  }

  double _parseNamedDurationPart(String text, String unit) {
    final match = RegExp(
      '(-?\\d+(?:[\\.,]\\d+)?)\\s*$unit',
      caseSensitive: false,
    ).firstMatch(text);
    return _parseNumber(match?.group(1)) ?? 0;
  }

  double? _parseFilamentLengthMm(String? rawValue) {
    if (rawValue == null || rawValue.trim().isEmpty) return null;
    final lower = rawValue.toLowerCase();

    if (lower.contains('m') && !lower.contains('[mm]')) {
      final values = RegExp(r'(-?\d+(?:[\.,]\d+)?)')
          .allMatches(rawValue)
          .map((match) => _parseNumber(match.group(1)))
          .whereType<double>()
          .toList();
      if (values.isEmpty) return null;
      return values.fold<double>(0, (sum, value) => sum + value) * 1000;
    }

    return _parseNumber(rawValue);
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
    final foundCount = [
      estimatedDuration,
      filamentLengthMm,
      filamentWeightG,
      layerHeightMm,
    ].where((value) => value != null).length;
    return foundCount > 0 && foundCount < 4;
  }

  void _collectRaw(Map<String, String> raw, String key, String? value) {
    if (value == null || value.trim().isEmpty) return;
    raw[key] = value.trim();
  }
}
