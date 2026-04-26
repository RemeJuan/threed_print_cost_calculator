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

    if (!pickedFile.hasSupportedExtension) {
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
        error: GCodeImportError.unsupportedType,
      );
      return;
    }

    state = GCodeImportState.loading(selectedFileName: pickedFile.name);

    try {
      final result = await ref
          .read(gcodeImportServiceProvider)
          .importPickedFile(pickedFile);
      if (!result.hasAnyExtractedMetadata) {
        state = GCodeImportState.failure(
          selectedFileName: pickedFile.name,
          error: GCodeImportError.unsupportedFile,
        );
        return;
      }

      state = GCodeImportState.success(
        selectedFileName: pickedFile.name,
        result: result,
      );
    } catch (_) {
      state = GCodeImportState.failure(
        selectedFileName: pickedFile.name,
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
    this.result,
    this.error,
  });

  const GCodeImportState.loading({required String selectedFileName})
    : this(
        status: GCodeImportStatus.loading,
        selectedFileName: selectedFileName,
      );

  const GCodeImportState.success({
    required String selectedFileName,
    required GCodeImportResult result,
  }) : this(
         status: GCodeImportStatus.success,
         selectedFileName: selectedFileName,
         result: result,
       );

  const GCodeImportState.failure({
    required String selectedFileName,
    required GCodeImportError error,
  }) : this(
         status: GCodeImportStatus.failure,
         selectedFileName: selectedFileName,
         error: error,
       );

  final GCodeImportStatus status;
  final String? selectedFileName;
  final GCodeImportResult? result;
  final GCodeImportError? error;
}
