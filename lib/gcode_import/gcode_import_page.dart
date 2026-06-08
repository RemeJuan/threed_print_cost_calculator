import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/batch_costing/batch_gcode_import_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_file_picker.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_actions.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_feedback_entry_point.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_header.dart';
import 'package:threed_print_cost_calculator/gcode_import/widgets/gcode_import_summary_card.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

import 'gcode_import_controller.dart';

class GCodeImportPage extends ConsumerStatefulWidget {
  const GCodeImportPage({super.key, this.source = 'unknown'});

  final String source;

  @override
  ConsumerState<GCodeImportPage> createState() => _GCodeImportPageState();
}

class _GCodeImportPageState extends ConsumerState<GCodeImportPage> {
  bool _multiMode = false;
  bool _hasLoggedImportStarted = false;
  List<GCodePickedFile> _multiFiles = const [];

  @override
  void initState() {
    super.initState();
    AppAnalytics.safeLog(() => AppAnalytics.gcodeImportOpened());
  }

  @override
  void dispose() {
    if (!_multiMode) {
      AppAnalytics.safeLog(() => AppAnalytics.gcodeImportAbandoned());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(gcodeImportControllerProvider);
    final controller = ref.read(gcodeImportControllerProvider.notifier);
    final parseStatus = state.result?.hasPartialMetadata == true
        ? 'partial'
        : 'success';
    final fileSizeBytes = state.selectedFileSizeBytes ?? 0;

    return Scaffold(
      appBar: AppScreenHeader(
        title: _multiMode
            ? l10n.batchGcodeImportTitle
            : l10n.importGcodePageTitle,
      ),
      body: SafeArea(
        child: _multiMode
            ? BatchGCodeImportPage(initialFiles: _multiFiles, embedded: true)
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GCodeImportHeader(text: l10n.importGcodeIntro),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        key: const ValueKey<String>(
                          'gcode_import.select_file.button',
                        ),
                        onPressed: state.status == GCodeImportStatus.loading
                            ? null
                            : () => _pickFiles(controller),
                        icon: const Icon(Icons.folder_open),
                        label: state.result == null
                            ? l10n.importGcodeSelectFileButton
                            : l10n.importGcodePickAnotherButton,
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                        ),
                        const SizedBox(height: 16),
                        GCodeImportActions(
                          l10n: l10n,
                          onPressed: _isPrimaryActionEnabled(state.result!)
                              ? () => _handlePrimaryAction(
                                  context,
                                  ref,
                                  l10n,
                                  result: state.result!,
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
              ),
      ),
    );
  }

  Future<void> _pickFiles(GCodeImportController controller) async {
    _logImportStartedIfNeeded();
    final policy = ref.read(premiumAccessPolicyProvider);
    if (policy.batchGcodeImport().allowed) {
      final files = await ref.read(gcodeImportFilePickerProvider).pickMany();
      if (!mounted || files.isEmpty) return;
      if (files.length > 1) {
        setState(() {
          _multiMode = true;
          _multiFiles = files;
        });
        return;
      }
      await controller.parsePickedFile(files.single);
      return;
    }

    final file = await ref.read(gcodeImportFilePickerProvider).pick();
    if (!mounted || file == null) return;
    await controller.parsePickedFile(file);
  }

  void _logImportStartedIfNeeded() {
    if (_hasLoggedImportStarted) return;
    _hasLoggedImportStarted = true;
    AppAnalytics.safeLog(
      () => AppAnalytics.gcodeImportStarted(source: widget.source),
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

  bool _isPrimaryActionEnabled(GCodeImportResult result) {
    return result.estimatedDuration != null || result.filamentWeightG != null;
  }

  void _handlePrimaryAction(
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
