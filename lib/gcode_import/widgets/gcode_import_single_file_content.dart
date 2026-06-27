import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

import 'gcode_import_actions.dart';
import 'gcode_import_feedback_entry_point.dart';
import 'gcode_import_header.dart';
import 'gcode_import_summary_card.dart';

class GCodeImportSingleFileContent extends StatelessWidget {
  const GCodeImportSingleFileContent({
    super.key,
    required this.l10n,
    required this.state,
    required this.fileSizeBytes,
    required this.parseStatus,
    required this.errorMessage,
    required this.isPrimaryActionEnabled,
    required this.onSelectFile,
    required this.onPrimaryAction,
  });

  final AppLocalizations l10n;
  final GCodeImportState state;
  final int fileSizeBytes;
  final String parseStatus;
  final String? errorMessage;
  final bool isPrimaryActionEnabled;
  final VoidCallback? onSelectFile;
  final VoidCallback? onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GCodeImportHeader(text: l10n.importGcodeIntro),
            const SizedBox(height: 16),
            AppPrimaryButton(
              key: const ValueKey<String>('gcode_import.select_file.button'),
              onPressed: onSelectFile,
              icon: const Icon(Icons.folder_open),
              label: state.result == null
                  ? l10n.importGcodeSelectFileButton
                  : l10n.importGcodePickAnotherButton,
            ),
            if (state.selectedFileName != null) ...[
              const SizedBox(height: 16),
              Text(
                '${l10n.importGcodeSelectedFileLabel}: ${state.selectedFileName}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (state.status == GCodeImportStatus.loading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (state.status == GCodeImportStatus.failure &&
                errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
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
                onPressed: isPrimaryActionEnabled ? onPrimaryAction : null,
              ),
            ],
            if (state.status == GCodeImportStatus.success ||
                state.status == GCodeImportStatus.failure) ...[
              const SizedBox(height: 16),
              GCodeImportFeedbackEntryPoint(
                state: state,
                importFailureContext:
                    state.status == GCodeImportStatus.failure &&
                        errorMessage != null
                    ? errorMessage
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
