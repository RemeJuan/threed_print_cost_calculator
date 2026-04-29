import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:riverpod/riverpod.dart';

import 'gcode_import_file_picker.dart';
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

    final bytes = await pickedFile.readAsBytes();
    final fileSizeBytes = bytes.length;

    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeFileSelected(
        fileSizeBytes: fileSizeBytes,
        slicer: 'unknown',
        hasPreview: false,
      ),
    );

    if (!pickedFile.hasSupportedExtension) {
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
