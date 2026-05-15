import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_section.dart';
import 'package:threed_print_cost_calculator/gcode_import/feedback/gcode_import_feedback_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';

import 'gcode_import_controller.dart';
import 'gcode_import_result.dart';

class GCodeImportPage extends HookConsumerWidget {
  const GCodeImportPage({super.key, this.source = 'unknown'});

  final String source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final batchCostingEnabled = ref.watch(batchCostingEnabledProvider);
    final quantity = useState(1);
    final quantityController = useTextEditingController(text: '1');
    final quantityFocusNode = useFocusNode();

    useEffect(() {
      AppAnalytics.safeLog(AppAnalytics.gcodeImportOpened);
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeImportStarted(source: source),
      );
      return () {
        AppAnalytics.safeLog(
          () => AppAnalytics.gcodeImportAbandoned(
            failureReason: GCodeFailureReason.cancelled,
          ),
        );
      };
    }, [source]);

    final state = ref.watch(gcodeImportControllerProvider);
    final controller = ref.read(gcodeImportControllerProvider.notifier);

    final parseStatus = state.result?.hasPartialMetadata == true
        ? 'partial'
        : 'success';
    final fileSizeBytes = state.selectedFileSizeBytes ?? 0;
    final canCreateBatchFromImport =
        batchCostingEnabled &&
        state.result?.estimatedDuration != null &&
        state.result?.filamentWeightG != null;

    useEffect(() {
      quantity.value = 1;
      quantityController.value = const TextEditingValue(
        text: '1',
        selection: TextSelection.collapsed(offset: 1),
      );
      return null;
    }, [state.selectedFilePath, state.selectedFileName]);

    useEffect(() {
      void handleFocusChange() {
        if (quantityFocusNode.hasFocus) return;
        final parsed = int.tryParse(quantityController.text);
        if (parsed != null && parsed >= 1) return;
        quantity.value = 1;
        quantityController.value = const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        );
      }

      quantityFocusNode.addListener(handleFocusChange);
      return () => quantityFocusNode.removeListener(handleFocusChange);
    }, [quantityController, quantityFocusNode]);

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
                        Text(
                          _slicerLabel(l10n, state.result!.slicer),
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeDurationLabel,
                        Text(
                          state.result!.estimatedDuration == null
                              ? l10n.importGcodeMissingValue
                              : _formatDuration(
                                  state.result!.estimatedDuration!,
                                ),
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeFilamentWeightLabel,
                        Text(
                          state.result!.filamentWeightG == null
                              ? l10n.importGcodeMissingValue
                              : '${state.result!.filamentWeightG!.toStringAsFixed(2)} ${l10n.gramsSuffix}',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeFilamentLengthLabel,
                        Text(
                          state.result!.filamentLengthMm == null
                              ? l10n.importGcodeMissingValue
                              : '${state.result!.filamentLengthMm!.toStringAsFixed(2)} mm',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _summaryRow(
                        context,
                        l10n.importGcodeLayerHeightLabel,
                        Text(
                          state.result!.layerHeightMm == null
                              ? l10n.importGcodeMissingValue
                              : '${state.result!.layerHeightMm!.toStringAsFixed(2)} mm',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      _summaryRow(
                        context,
                        _previewLabel(l10n, state.result!),
                        _previewValueWidget(
                          context,
                          l10n,
                          state.result!,
                          fileSizeBytes: fileSizeBytes,
                          parseStatus: parseStatus,
                        ),
                      ),
                      if (_shouldShowPreviewNote(state.result!)) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.importGcodePreviewCuraNote,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        l10n.importGcodeCalculatorNote,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (batchCostingEnabled) ...[
                        const SizedBox(height: 16),
                        FocusSafeTextField(
                          key: const ValueKey<String>(
                            'gcode_import.quantity.field',
                          ),
                          controller: quantityController,
                          focusNode: quantityFocusNode,
                          externalText: quantity.value.toString(),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          inputNormalizer: (value) =>
                              normalizeLeadingZeroNumericInput(
                                value,
                                allowDecimal: false,
                              ),
                          decoration: InputDecoration(
                            labelText: l10n.importGcodeQuantityLabel,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            quantity.value = parsed != null && parsed >= 1
                                ? parsed
                                : 1;
                          },
                        ),
                        if (quantity.value > 1 &&
                            !canCreateBatchFromImport) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.importGcodeBatchRequiresDetectedValues,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const ValueKey<String>('gcode_import.apply.button'),
                onPressed:
                    _isPrimaryActionEnabled(
                      state.result!,
                      quantity: quantity.value,
                      canCreateBatchFromImport: canCreateBatchFromImport,
                    )
                    ? () => _handlePrimaryAction(
                        context,
                        ref,
                        l10n,
                        result: state.result!,
                        selectedFileName: state.selectedFileName,
                        selectedFilePath: state.selectedFilePath,
                        quantity: quantity.value,
                        fileSizeBytes: fileSizeBytes,
                        parseStatus: parseStatus,
                      )
                    : null,
                child: Text(
                  quantity.value > 1
                      ? l10n.importGcodeCreateBatchButton
                      : l10n.importGcodeUseValuesButton,
                ),
              ),
            ],
            if (state.status == GCodeImportStatus.success ||
                state.status == GCodeImportStatus.failure) ...[
              const SizedBox(height: 16),
              GCodeImportFeedbackSection(
                importState: state,
                importFailureContext:
                    state.status == GCodeImportStatus.failure &&
                        state.error != null
                    ? _errorMessage(l10n, state.error!)
                    : null,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GCodeImportFeedbackPage(
                        importedFileName: state.selectedFileName,
                        importedFilePath: state.selectedFilePath,
                        importFailureContext:
                            state.status == GCodeImportStatus.failure &&
                                state.error != null
                            ? _errorMessage(l10n, state.error!)
                            : null,
                      ),
                    ),
                  );
                },
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
      GCodeImportError.tooLarge => l10n.importGcodeTooLargeError(
        gCodeImportMaxSizeMb.toString(),
      ),
      GCodeImportError.readFailed => l10n.importGcodeReadError,
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

  bool _isPrimaryActionEnabled(
    GCodeImportResult result, {
    required int quantity,
    required bool canCreateBatchFromImport,
  }) {
    if (quantity > 1) {
      return canCreateBatchFromImport;
    }

    return result.estimatedDuration != null || result.filamentWeightG != null;
  }

  void _handlePrimaryAction(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required GCodeImportResult result,
    required String? selectedFileName,
    required String? selectedFilePath,
    required int quantity,
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

    if (quantity > 1) {
      final notifier = ref.read(batchCostingProvider.notifier);
      notifier.reset();
      notifier.addItem(
        BatchCostingItem.fromGCodeImport(
          id: 'gcode-${DateTime.now().microsecondsSinceEpoch}',
          displayName: selectedFileName ?? l10n.importGcodeSelectedFileLabel,
          quantity: quantity,
          importResult: result,
          sourceFileName: selectedFileName,
          sourcePath: selectedFilePath,
        ),
      );
      AppAnalytics.safeLog(
        () => AppAnalytics.gcodeFlowCompleted(
          slicer: result.slicer.name,
          hasPreview: result.hasPreviewMetadata,
          fileSizeBytes: fileSizeBytes,
          parseStatus: parseStatus,
        ),
      );
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const BatchCostingPage()));
      return;
    }

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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.importGcodeAppliedMessage)));
    Navigator.of(context).pop();
  }

  Widget _previewValueWidget(
    BuildContext context,
    AppLocalizations l10n,
    GCodeImportResult result, {
    required int fileSizeBytes,
    required String parseStatus,
  }) {
    final previewBytes = result.previewImageBytes;
    if (previewBytes == null) {
      return _previewPlaceholder(context, l10n);
    }

    if (!result.hasSafePreview) {
      return Text(
        l10n.importGcodePreviewUnavailable,
        textAlign: TextAlign.end,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final isLowRes =
        (result.previewWidth ?? 0) < 128 || (result.previewHeight ?? 0) < 128;

    if (isLowRes) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AppAnalytics.safeLog(
                  () => AppAnalytics.gcodePreviewViewed(
                    slicer: result.slicer.name,
                    hasPreview: result.hasPreviewMetadata,
                    fileSizeBytes: fileSizeBytes,
                    parseStatus: parseStatus,
                  ),
                );
                _showPreviewDialog(context, l10n, previewBytes);
              },
              child: Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: Image.memory(
                  previewBytes,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  gaplessPlayback: true,
                  isAntiAlias: false,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: () {
          AppAnalytics.safeLog(
            () => AppAnalytics.gcodePreviewViewed(
              slicer: result.slicer.name,
              hasPreview: result.hasPreviewMetadata,
              fileSizeBytes: fileSizeBytes,
              parseStatus: parseStatus,
            ),
          );
          _showPreviewDialog(context, l10n, previewBytes);
        },
        icon: const Icon(Icons.launch),
        label: Text(l10n.importGcodePreviewView),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  String _previewLabel(AppLocalizations l10n, GCodeImportResult result) {
    final width = result.previewWidth;
    final height = result.previewHeight;
    if (width != null && height != null && (width < 128 || height < 128)) {
      return '${l10n.importGcodePreviewLabel} · $width×$height';
    }
    return l10n.importGcodePreviewLabel;
  }

  Widget _previewPlaceholder(BuildContext context, AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.importGcodePreviewUnavailable,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowPreviewNote(GCodeImportResult result) {
    return result.slicer == GCodeSlicer.cura &&
        result.previewImageBytes == null;
  }

  Future<void> _showPreviewDialog(
    BuildContext context,
    AppLocalizations l10n,
    Uint8List bytes,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (dialogContext) {
        final mediaQuery = MediaQuery.of(dialogContext);
        final maxWidth = mediaQuery.size.width - 32;
        final maxHeight = mediaQuery.size.height - 32;

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Image.memory(
                        bytes,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.none,
                        gaplessPlayback: true,
                        isAntiAlias: false,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Text(
                            l10n.importGcodePreviewDecodeFailed,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: false,
                    left: false,
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(
                        dialogContext,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryRow(BuildContext context, String label, Widget value) {
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
          Expanded(flex: 3, child: value),
        ],
      ),
    );
  }
}
