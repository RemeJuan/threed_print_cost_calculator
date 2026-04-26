import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

import 'gcode_import_controller.dart';
import 'gcode_import_result.dart';

class GCodeImportPage extends HookConsumerWidget {
  const GCodeImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(gcodeImportControllerProvider);
    final controller = ref.read(gcodeImportControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importGcodePageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.importGcodeIntro,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: const ValueKey<String>('gcode_import.select_file.button'),
              onPressed: state.status == GCodeImportStatus.loading
                  ? null
                  : controller.pickAndParse,
              icon: const Icon(Icons.folder_open),
              label: Text(
                state.result == null
                    ? l10n.importGcodeSelectFileButton
                    : l10n.importGcodePickAnotherButton,
              ),
            ),
            if (state.selectedFileName != null) ...[
              const SizedBox(height: 16),
              Text(
                '${l10n.importGcodeSelectedFileLabel}: ${state.selectedFileName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (state.status == GCodeImportStatus.loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (state.status == GCodeImportStatus.failure &&
                state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage(l10n, state.error!),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            if (state.result != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.importGcodeSummaryTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      _summaryRow(
                        context,
                        l10n.importGcodeSlicerLabel,
                        _slicerLabel(l10n, state.result!.slicer),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeDurationLabel,
                        state.result!.estimatedDuration == null
                            ? l10n.importGcodeMissingValue
                            : _formatDuration(state.result!.estimatedDuration!),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeFilamentWeightLabel,
                        state.result!.filamentWeightG == null
                            ? l10n.importGcodeMissingValue
                            : '${state.result!.filamentWeightG!.toStringAsFixed(2)} ${l10n.gramsSuffix}',
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeFilamentLengthLabel,
                        state.result!.filamentLengthMm == null
                            ? l10n.importGcodeMissingValue
                            : '${state.result!.filamentLengthMm!.toStringAsFixed(2)} mm',
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeLayerHeightLabel,
                        state.result!.layerHeightMm == null
                            ? l10n.importGcodeMissingValue
                            : '${state.result!.layerHeightMm!.toStringAsFixed(2)} mm',
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodePreviewLabel,
                        _previewLabel(l10n, state.result!),
                      ),
                      if (state.result!.warnings.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.importGcodeWarningsTitle,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        ...state.result!.warnings.map(
                          (warning) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '• ${_warningMessage(l10n, warning.code)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        l10n.importGcodeSupportedSlicersNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.importGcodeCalculatorNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const ValueKey<String>('gcode_import.apply.button'),
                onPressed:
                    state.result!.estimatedDuration == null &&
                        state.result!.filamentWeightG == null
                    ? null
                    : () {
                        ref
                            .read(calculatorProvider.notifier)
                            .applyImportedValues(
                              estimatedDuration:
                                  state.result!.estimatedDuration,
                              filamentWeightGrams:
                                  state.result!.filamentWeightG,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.importGcodeAppliedMessage),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                child: Text(l10n.importGcodeUseValuesButton),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _errorMessage(AppLocalizations l10n, GCodeImportError error) {
    return switch (error) {
      GCodeImportError.unsupportedType => l10n.importGcodeUnsupportedTypeError,
      GCodeImportError.unsupportedFile => l10n.importGcodeUnsupportedFileError,
      GCodeImportError.readFailed => l10n.importGcodeReadError,
    };
  }

  String _warningMessage(
    AppLocalizations l10n,
    GCodeParseWarningCode warningCode,
  ) {
    return switch (warningCode) {
      GCodeParseWarningCode.unknownSlicer =>
        l10n.importGcodeWarningUnknownSlicer,
      GCodeParseWarningCode.missingDuration =>
        l10n.importGcodeWarningMissingDuration,
      GCodeParseWarningCode.missingFilament =>
        l10n.importGcodeWarningMissingFilament,
      GCodeParseWarningCode.missingFilamentWeight =>
        l10n.importGcodeWarningMissingFilamentWeight,
      GCodeParseWarningCode.partialMetadata =>
        l10n.importGcodeWarningPartialMetadata,
    };
  }

  String _slicerLabel(AppLocalizations l10n, GCodeSlicer slicer) {
    return slicer.label(l10n);
  }

  String _formatDuration(Duration duration) {
    final roundedMinutes = (duration.inSeconds / 60).round();
    final hours = roundedMinutes ~/ 60;
    final minutes = roundedMinutes % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  String _previewLabel(AppLocalizations l10n, GCodeImportResult result) {
    final preview = result.previewMetadata;
    if (preview == null || !preview.present) {
      return l10n.importGcodePreviewUnavailable;
    }

    final size = preview.width == null || preview.height == null
        ? null
        : '${preview.width}x${preview.height}';
    return [
      l10n.importGcodePreviewAvailable,
      preview.format,
      size,
    ].whereType<String>().join(' · ');
  }

  Widget _summaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
