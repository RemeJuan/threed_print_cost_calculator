part of 'gcode_import_parser.dart';

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

    extractedDuration ??= firstMatchingValueInLine(line, _durationPatterns);
    _collectRaw(raw, 'estimatedDuration', extractedDuration);

    _collectFirstRaw(
      'filamentLengthMm',
      firstMatchingValueInLine(line, _filamentLengthMmPatterns),
    );
    _collectFirstRaw(
      'filamentWeightG',
      firstMatchingValueInLine(line, _filamentWeightPatterns),
    );
    _collectFirstRaw(
      'layerHeightMm',
      firstMatchingValueInLine(line, _layerHeightPatterns),
    );

    layerHeightMm ??= _parseNumber(
      firstMatchingValueInLine(line, _layerHeightPatterns),
    );

    _addSummedValue(
      line,
      _filamentLengthMmPatterns,
      unit: 'mm',
      apply: (value) {
        _filamentLengthMmTotal += value;
        _hasFilamentLengthMm = true;
      },
    );
    _addSummedValue(
      line,
      _filamentLengthCmPatterns,
      unit: 'cm',
      apply: (value) {
        _filamentLengthCmTotal += value;
        _hasFilamentLengthCm = true;
      },
    );
    _addSummedValue(
      line,
      _filamentLengthMPatterns,
      unit: 'm',
      apply: (value) {
        _filamentLengthMTotal += value;
        _hasFilamentLengthM = true;
      },
    );
    _addSummedValue(
      line,
      _filamentWeightPatterns,
      unit: 'g',
      apply: (value) {
        _filamentWeightGTotal += value;
        _hasFilamentWeightG = true;
      },
    );

    if (!mixedMaterials && lineHasMixedOrAmbiguousMaterials(line)) {
      mixedMaterials = true;
    }

    _consumePreviewLine(line);
  }

  GCodeImportResult build() {
    _finishPreviewCandidate();

    final duration = parseDuration(extractedDuration);
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
    if (isPartialMetadata(
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
    _collectRaw(raw, key, value);
  }

  void _addSummedValue(
    String line,
    List<RegExp> patterns, {
    required String unit,
    required void Function(double value) apply,
  }) {
    final rawValue = firstMatchingValueInLine(line, patterns);
    if (rawValue == null) return;
    final value = sumRawValue(rawValue, unit: unit);
    if (value != null) {
      apply(value);
    }
  }

  void _consumePreviewLine(String line) {
    final beginMatch = _thumbnailBeginRegex.firstMatch(line);
    final end = _thumbnailEndRegex.hasMatch(line);

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
    if (width > _maxPreviewDimension || height > _maxPreviewDimension) {
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

  void _collectRaw(Map<String, String> raw, String key, String? value) {
    if (value == null || value.trim().isEmpty) return;
    raw[key] = value.trim();
  }
}
