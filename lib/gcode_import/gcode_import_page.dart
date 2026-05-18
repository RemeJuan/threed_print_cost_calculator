import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_costing_page.dart';
import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/batch_costing_visibility.dart';

import 'gcode_import_controller.dart';
import 'gcode_import_result.dart';
import 'widgets/gcode_import_actions.dart';
import 'widgets/gcode_import_feedback_entry_point.dart';
import 'widgets/gcode_import_header.dart';
import 'widgets/gcode_import_summary_card.dart';

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
            GCodeImportHeader(text: l10n.importGcodeIntro),
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
              GCodeImportSummaryCard(
                result: state.result!,
                l10n: l10n,
                fileSizeBytes: fileSizeBytes,
                parseStatus: parseStatus,
                batchCostingEnabled: batchCostingEnabled,
                quantity: quantity,
                quantityController: quantityController,
                quantityFocusNode: quantityFocusNode,
                canCreateBatchFromImport: canCreateBatchFromImport,
                onQuantityChanged: (value) {
                  final parsed = int.tryParse(value);
                  quantity.value = parsed != null && parsed >= 1 ? parsed : 1;
                },
              ),
              const SizedBox(height: 16),
              GCodeImportActions(
                l10n: l10n,
                quantity: quantity.value,
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
              ),
            ],
            if (state.status == GCodeImportStatus.success ||
                state.status == GCodeImportStatus.failure) ...[
              const SizedBox(height: 16),
              GCodeImportFeedbackEntryPoint(
                state: state,
                importFailureContext:
                    state.status == GCodeImportStatus.failure &&
                        state.error != null
                    ? _errorMessage(l10n, state.error!)
                    : null,
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
}
