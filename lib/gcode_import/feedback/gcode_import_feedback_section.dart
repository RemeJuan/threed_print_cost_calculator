import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/gcode_import/gcode_import_controller.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class GCodeImportFeedbackSection extends StatelessWidget {
  const GCodeImportFeedbackSection({
    required this.importState,
    required this.importFailureContext,
    required this.onPressed,
    super.key,
  });

  final GCodeImportState importState;
  final String? importFailureContext;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.gcodeImportFeedbackBetaFeature,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.gcodeImportFeedbackBetaDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (importState.selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.importGcodeSelectedFileLabel}: ${importState.selectedFileName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (importFailureContext != null) ...[
              const SizedBox(height: 8),
              Text(
                importFailureContext!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: AppPrimaryButton(
                onPressed: onPressed,
                label: l10n.gcodeImportFeedbackSendCta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
