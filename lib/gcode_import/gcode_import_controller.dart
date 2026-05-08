import 'dart:convert';
import 'dart:typed_data';

import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_import_diagnostics.dart';
import 'gcode_import_file_picker.dart';
import 'gcode_import_file_reader.dart';
import 'gcode_import_result.dart';
import 'gcode_import_service.dart';

final gcodeImportControllerProvider =
    NotifierProvider<GCodeImportController, GCodeImportState>(
      GCodeImportController.new,
    );

class GCodeImportController extends Notifier<GCodeImportState> {
  @override
  GCodeImportState build() => const GCodeImportState();

  Future<void> pickAndParse() async {
    final pickedFile = await ref.read(gcodeImportFilePickerProvider).pick();
    if (pickedFile == null) return;

    final fileType = _fileTypeFromName(pickedFile.name);
    logGCodeImportBreadcrumb(
      'import_started',
      fileName: pickedFile.name,
      originalFileName: pickedFile.originalName,
      mimeType: pickedFile.mimeType,
      fileSizeBytes: pickedFile.size,
    );
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeFileSelected(fileType: fileType),
    );

    final fileSize = await resolvePickedGCodeFileSize(pickedFile);
    logGCodeImportBreadcrumb(
      'file_metadata_resolved',
      fileName: pickedFile.name,
      originalFileName: pickedFile.originalName,
      mimeType: pickedFile.mimeType,
      fileSizeBytes: fileSize,
    );

    if (fileSize != null && fileSize > _maxGCodeImportBytes) {
      logGCodeImportBreadcrumb(
        'file_rejected_size',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSize,
        reason: 'too_large',
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSize,
          failureReason: GCodeFailureReason.fileTooLarge,
        ),
      );
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSize,
        error: GCodeImportError.tooLarge,
      );
      return;
    }

    final fileSizeBytes = fileSize ?? 0;
    final validation = await _validateFile(pickedFile);
    if (validation.error != null) {
      final error = validation.error!;
      final reason = error == GCodeImportError.tooLarge
          ? 'too_large'
          : 'unsupported_type';
      final analyticsReason = error == GCodeImportError.tooLarge
          ? GCodeFailureReason.fileTooLarge
          : GCodeFailureReason.unsupportedContent;
      logGCodeImportBreadcrumb(
        error == GCodeImportError.tooLarge
            ? 'file_rejected_size'
            : 'file_rejected_type',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSizeBytes,
        reason: reason,
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
          failureReason: analyticsReason,
        ),
      );
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        error: error,
      );
      return;
    }

    state = GCodeImportState.loading(
      selectedFileName: pickedFile.name,
      selectedFilePath: pickedFile.path,
      selectedFileSizeBytes: fileSizeBytes,
    );

    try {
      final result = await ref
          .read(gcodeImportServiceProvider)
          .importPickedFile(pickedFile);
      if (!result.hasAnyExtractedMetadata) {
        logGCodeImportBreadcrumb(
          'parse_failed',
          fileName: pickedFile.name,
          originalFileName: pickedFile.originalName,
          mimeType: pickedFile.mimeType,
          fileSizeBytes: fileSizeBytes,
          reason: 'no_metadata',
        );
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodeParseFailed(
            slicer: result.slicer.name,
            hasPreview: result.hasPreviewMetadata,
            fileSizeBytes: fileSizeBytes,
            failureReason: GCodeFailureReason.parseError,
          ),
        );
        state = GCodeImportState.failure(
          selectedFileName: pickedFile.name,
          selectedFilePath: pickedFile.path,
          selectedFileSizeBytes: fileSizeBytes,
          error: GCodeImportError.unsupportedFile,
        );
        return;
      }

      final parseStatus = result.hasPartialMetadata ? 'partial' : 'success';
      AppAnalytics.safeLog(
        () => parseStatus == 'partial'
            ? AppAnalytics.gcodeParsePartial(
                slicer: result.slicer.name,
                hasPreview: result.hasPreviewMetadata,
                fileSizeBytes: fileSizeBytes,
              )
            : AppAnalytics.gcodeParseSuccess(
                slicer: result.slicer.name,
                hasPreview: result.hasPreviewMetadata,
                fileSizeBytes: fileSizeBytes,
              ),
      );
      logGCodeImportBreadcrumb(
        'import_succeeded',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSizeBytes,
      );

      state = GCodeImportState.success(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        result: result,
      );
    } catch (_) {
      logGCodeImportBreadcrumb(
        'parse_failed',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSizeBytes,
        reason: 'exception',
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
          failureReason: GCodeFailureReason.readFailed,
        ),
      );
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        error: GCodeImportError.readFailed,
      );
    }
  }

  String _fileTypeFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return 'unknown';
    return name.substring(dotIndex + 1).toLowerCase();
  }
}

class _GCodeValidationResult {
  const _GCodeValidationResult._({this.error});

  final GCodeImportError? error;

  static const supported = _GCodeValidationResult._();

  static const unsupportedType = _GCodeValidationResult._(
    error: GCodeImportError.unsupportedType,
  );

  static const tooLarge = _GCodeValidationResult._(
    error: GCodeImportError.tooLarge,
  );
}

const _maxGCodeImportBytes = 50 * 1024 * 1024;
const gCodeImportMaxSizeMb = _maxGCodeImportBytes ~/ (1024 * 1024);
const _sniffBytesLimit = 64 * 1024;

Future<_GCodeValidationResult> _validateFile(GCodePickedFile file) async {
  final fileSize = await resolvePickedGCodeFileSize(file);
  if (fileSize != null && fileSize > _maxGCodeImportBytes) {
    return _GCodeValidationResult.tooLarge;
  }

  final hasSupportedName = file.candidateNames.any(hasSupportedGCodeExtension);
  final mimeType = file.mimeType?.toLowerCase();
  final shouldInspectContent =
      !hasSupportedName ||
      mimeType == null ||
      mimeType == 'application/octet-stream' ||
      !_looksLikeTextualGCodeMimeType(mimeType);

  if (!shouldInspectContent) {
    return _GCodeValidationResult.supported;
  }

  final bytes = await readPickedGCodeSample(file, _sniffBytesLimit);
  final text = _sniffText(bytes);
  if (!_looksTextLike(text)) {
    return _GCodeValidationResult.unsupportedType;
  }

  if (hasSupportedName) {
    return _GCodeValidationResult.supported;
  }

  return _looksLikeGCode(text)
      ? _GCodeValidationResult.supported
      : _GCodeValidationResult.unsupportedType;
}

String _sniffText(Uint8List bytes) {
  final sample = bytes.length > _sniffBytesLimit
      ? bytes.sublist(0, _sniffBytesLimit)
      : bytes;
  return utf8.decode(sample, allowMalformed: true);
}

bool _looksLikeGCode(String text) {
  if (!_looksTextLike(text)) return false;

  final markers = <RegExp>[
    RegExp(r';\s*FLAVOR\s*:', caseSensitive: false),
    RegExp(r';\s*Generated with', caseSensitive: false),
    RegExp(r';\s*TIME\s*:', caseSensitive: false),
    RegExp(r';\s*filament used', caseSensitive: false),
    RegExp(r'\bG0\s', caseSensitive: false),
    RegExp(r'\bG1\s', caseSensitive: false),
    RegExp(r'\bM104\b', caseSensitive: false),
    RegExp(r'\bM109\b', caseSensitive: false),
    RegExp(r'\bM140\b', caseSensitive: false),
    RegExp(r'\bM190\b', caseSensitive: false),
  ];
  return markers.any((pattern) => pattern.hasMatch(text));
}

bool _looksLikeTextualGCodeMimeType(String mimeType) {
  return mimeType.startsWith('text/') ||
      mimeType.contains('gcode') ||
      mimeType.contains('g-code') ||
      mimeType == 'application/x-gcode' ||
      mimeType == 'application/gcode';
}

bool _looksTextLike(String text) {
  if (text.isEmpty) return false;
  final controlCount = text.runes
      .where((r) => r < 32 && r != 9 && r != 10 && r != 13)
      .length;
  return controlCount * 20 < text.length;
}

enum GCodeImportStatus { idle, loading, success, failure }

enum GCodeImportError { unsupportedType, unsupportedFile, tooLarge, readFailed }

class GCodeImportState {
  const GCodeImportState({
    this.status = GCodeImportStatus.idle,
    this.selectedFileName,
    this.selectedFilePath,
    this.selectedFileSizeBytes,
    this.result,
    this.error,
  });

  const GCodeImportState.loading({
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
  }) : this(
         status: GCodeImportStatus.loading,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
       );

  const GCodeImportState.success({
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
    required GCodeImportResult result,
  }) : this(
         status: GCodeImportStatus.success,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
         result: result,
       );

  const GCodeImportState.failure({
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
    required GCodeImportError error,
  }) : this(
         status: GCodeImportStatus.failure,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
         error: error,
       );

  final GCodeImportStatus status;
  final String? selectedFileName;
  final String? selectedFilePath;
  final int? selectedFileSizeBytes;
  final GCodeImportResult? result;
  final GCodeImportError? error;
}
