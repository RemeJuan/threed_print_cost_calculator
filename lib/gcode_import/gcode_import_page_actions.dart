import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class GCodeImportPageActions {
  const GCodeImportPageActions();

  String errorMessage(AppLocalizations l10n, GCodeImportError error) {
    return switch (error) {
      GCodeImportError.unsupportedType => l10n.importGcodeUnsupportedTypeError,
      GCodeImportError.unsupportedFile => l10n.importGcodeUnsupportedFileError,
      GCodeImportError.tooLarge => l10n.importGcodeTooLargeError(
        gCodeImportMaxSizeMb.toString(),
      ),
      GCodeImportError.readFailed => l10n.importGcodeReadError,
    };
  }

  bool isPrimaryActionEnabled(GCodeImportResult result) {
    return result.estimatedDuration != null || result.filamentWeightG != null;
  }

  void handlePrimaryAction(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required GCodeImportResult result,
    required int fileSizeBytes,
    required String parseStatus,
  }) {
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeImportSuccess(
        hasPrintTime: result.estimatedDuration != null,
        hasFilamentUsage:
            result.filamentWeightG != null || result.filamentLengthMm != null,
        hasPreview: result.hasPreviewMetadata,
      ),
    );
    ref
        .read(calculatorProvider.notifier)
        .applyImportedValues(
          estimatedDuration: result.estimatedDuration,
          filamentWeightGrams: result.filamentWeightG,
        );
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeFlowCompleted(
        slicer: result.slicer.name,
        hasPreview: result.hasPreviewMetadata,
        fileSizeBytes: fileSizeBytes,
        parseStatus: parseStatus,
      ),
    );
    BotToast.showText(text: l10n.importGcodeAppliedMessage);
    Navigator.of(context).pop();
  }
}
