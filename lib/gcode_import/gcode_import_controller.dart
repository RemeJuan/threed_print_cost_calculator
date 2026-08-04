import 'dart:async';

import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_file_validator.dart';
import 'gcode_import_diagnostics.dart';
import 'gcode_import_file_picker.dart';
import 'gcode_import_file_reader.dart';
import 'gcode_import_result.dart';
import 'gcode_import_service.dart';

export 'gcode_file_validator.dart' show GCodeImportError, gCodeImportMaxSizeMb;

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
    await parsePickedFile(
      pickedFile,
      attemptId: AppAnalytics.newGcodeImportAttemptId(),
    );
  }

  Future<void> parsePickedFile(
    GCodePickedFile pickedFile, {
    required String attemptId,
  }) async {
    state = GCodeImportState.loading(
      attemptId: attemptId,
      selectedFileName: pickedFile.name,
      selectedFilePath: pickedFile.path,
      selectedFileSizeBytes: pickedFile.size ?? 0,
    );
    final fileType = _fileTypeFromName(pickedFile.name);
    logGCodeImportBreadcrumb(
      'import_started',
      fileName: pickedFile.name,
      originalFileName: pickedFile.originalName,
      mimeType: pickedFile.mimeType,
      fileSizeBytes: pickedFile.size,
    );
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeFileSelected(
        attemptId: attemptId,
        fileType: fileType,
      ),
    );

    int? fileSize;
    try {
      fileSize = await resolvePickedGCodeFileSize(pickedFile);
      if (!_isActiveAttempt(attemptId)) return;
      logGCodeImportBreadcrumb(
        'file_metadata_resolved',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSize,
      );
    } catch (error, stackTrace) {
      await captureGCodeImportFailure(
        stage: 'metadata_resolution',
        error: error,
        stackTrace: stackTrace,
        file: pickedFile,
        category: 'metadata_exception',
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          attemptId: attemptId,
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: 0,
          failureReason: GCodeFailureReason.readFailed,
        ),
      );
      return;
    }

    if (fileSize != null && fileSize > maxGCodeImportBytes) {
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
          attemptId: attemptId,
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSize ?? 0,
          failureReason: GCodeFailureReason.fileTooLarge,
        ),
      );
      if (!_isActiveAttempt(attemptId)) return;
      state = GCodeImportState.failure(
        attemptId: attemptId,
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSize,
        error: GCodeImportError.tooLarge,
      );
      return;
    }

    final fileSizeBytes = fileSize ?? 0;
    final validation = await validateGCodeFile(pickedFile);
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
          attemptId: attemptId,
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
          failureReason: analyticsReason,
        ),
      );
      if (!_isActiveAttempt(attemptId)) return;
      state = GCodeImportState.failure(
        attemptId: attemptId,
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        error: error,
      );
      return;
    }

    try {
      final result = await ref
          .read(gcodeImportServiceProvider)
          .importPickedFile(pickedFile);
      if (!_isActiveAttempt(attemptId)) return;
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
            attemptId: attemptId,
            slicer: result.slicer.name,
            hasPreview: result.hasPreviewMetadata,
            fileSizeBytes: fileSizeBytes,
            failureReason: GCodeFailureReason.parseError,
          ),
        );
        state = GCodeImportState.failure(
          attemptId: attemptId,
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
                attemptId: attemptId,
                slicer: result.slicer.name,
                hasPreview: result.hasPreviewMetadata,
                fileSizeBytes: fileSizeBytes,
              )
            : AppAnalytics.gcodeParseSuccess(
                attemptId: attemptId,
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
        attemptId: attemptId,
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        result: result,
      );
    } catch (error, stackTrace) {
      if (!_isActiveAttempt(attemptId)) return;
      logGCodeImportBreadcrumb(
        'parse_failed',
        fileName: pickedFile.name,
        originalFileName: pickedFile.originalName,
        mimeType: pickedFile.mimeType,
        fileSizeBytes: fileSizeBytes,
        reason: 'exception',
      );
      await captureGCodeImportFailure(
        stage: 'command_parse',
        error: error,
        stackTrace: stackTrace,
        file: pickedFile,
        category: 'import_exception',
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeParseFailed(
          attemptId: attemptId,
          slicer: 'unknown',
          hasPreview: false,
          fileSizeBytes: fileSizeBytes,
          failureReason: GCodeFailureReason.readFailed,
        ),
      );
      state = GCodeImportState.failure(
        attemptId: attemptId,
        selectedFileName: pickedFile.name,
        selectedFilePath: pickedFile.path,
        selectedFileSizeBytes: fileSizeBytes,
        error: GCodeImportError.readFailed,
      );
    }
  }

  bool _isActiveAttempt(String attemptId) => state.activeAttemptId == attemptId;

  String _fileTypeFromName(String name) {
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == name.length - 1) return 'unknown';
    return name.substring(dotIndex + 1).toLowerCase();
  }
}

enum GCodeImportStatus { idle, loading, success, failure }

class GCodeImportState {
  const GCodeImportState({
    this.status = GCodeImportStatus.idle,
    this.activeAttemptId,
    this.selectedFileName,
    this.selectedFilePath,
    this.selectedFileSizeBytes,
    this.result,
    this.error,
  });

  const GCodeImportState.loading({
    required String attemptId,
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
  }) : this(
         status: GCodeImportStatus.loading,
         activeAttemptId: attemptId,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
       );

  const GCodeImportState.success({
    required String attemptId,
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
    required GCodeImportResult result,
  }) : this(
         status: GCodeImportStatus.success,
         activeAttemptId: attemptId,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
         result: result,
       );

  const GCodeImportState.failure({
    required String attemptId,
    required String selectedFileName,
    String? selectedFilePath,
    required int selectedFileSizeBytes,
    required GCodeImportError error,
  }) : this(
         status: GCodeImportStatus.failure,
         activeAttemptId: attemptId,
         selectedFileName: selectedFileName,
         selectedFilePath: selectedFilePath,
         selectedFileSizeBytes: selectedFileSizeBytes,
         error: error,
       );

  final GCodeImportStatus status;
  final String? activeAttemptId;
  final String? selectedFileName;
  final String? selectedFilePath;
  final int? selectedFileSizeBytes;
  final GCodeImportResult? result;
  final GCodeImportError? error;
}
