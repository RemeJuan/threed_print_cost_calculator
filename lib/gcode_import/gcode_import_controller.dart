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
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeFileSelected(fileType: fileType),
    );

    final fileSize = pickedFile.size;
    if (fileSize != null && fileSize > _maxGCodeImportBytes) {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSize,
        ),
      );
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSize,
        error: GCodeImportError.unsupportedType,
      );
      return;
    }

    final bytes = await pickedFile.readAsBytes();
    final fileSizeBytes = bytes.length;

    final validation = _validateFile(pickedFile, bytes);
    if (!validation.isSupported) {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
        ),
      );
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        error: GCodeImportError.unsupportedType,
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
          .importPickedBytes(bytes);
      if (!result.hasAnyExtractedMetadata) {
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodeParseFailed(
            slicer: result.slicer.name,
            hasPreview: result.hasPreviewMetadata,
            fileSizeBytes: fileSizeBytes,
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

      state = GCodeImportState.success(
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        result: result,
      );
    } catch (_) {
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
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
  const _GCodeValidationResult(this.isSupported);

  final bool isSupported;
}

const _maxGCodeImportBytes = 50 * 1024 * 1024;
const _sniffBytesLimit = 64 * 1024;

_GCodeValidationResult _validateFile(GCodePickedFile file, Uint8List bytes) {
  final ext = _fileExtension(file.name);
  final mimeType = file.mimeType?.toLowerCase();
  if (bytes.length > _maxGCodeImportBytes) {
    return const _GCodeValidationResult(false);
  }

  final text = _sniffText(bytes);
  if (!_looksTextLike(text)) {
    return const _GCodeValidationResult(false);
  }

  final supportedExtension = ext == '.gcode' || ext == '.gco' || ext == '.nc';
  final shouldInspectContent =
      !supportedExtension || mimeType == 'application/octet-stream';
  if (!shouldInspectContent) {
    return const _GCodeValidationResult(true);
  }

  return _looksLikeGCode(text)
      ? const _GCodeValidationResult(true)
      : const _GCodeValidationResult(false);
}

String _fileExtension(String name) {
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == name.length - 1) return '';
  return name.substring(dotIndex).toLowerCase();
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

bool _looksTextLike(String text) {
  if (text.isEmpty) return false;
  final controlCount = text.runes
      .where((r) => r < 32 && r != 9 && r != 10 && r != 13)
      .length;
  return controlCount * 20 < text.length;
}

enum GCodeImportStatus { idle, loading, success, failure }

enum GCodeImportError { unsupportedType, unsupportedFile, readFailed }

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
