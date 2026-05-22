import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class HistoryExportPreviewSheet extends StatelessWidget {
  const HistoryExportPreviewSheet({
    super.key,
    required this.csvPreview,
    required this.onDownloadPressed,
  });

  final String csvPreview;
  final VoidCallback onDownloadPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.historyExportPreviewTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.historyExportPreviewDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.historyExportPreviewSampleLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(kAppSpace12),
              decoration: BoxDecoration(
                color: PREVIEW_SURFACE,
                borderRadius: BorderRadius.circular(kAppSurfaceRadius),
              ),
              child: SelectableText(
                csvPreview,
                key: const ValueKey<String>('history.export.preview.csv'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TEXT_SECONDARY,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                key: const ValueKey<String>(
                  'history.export.preview.download.button',
                ),
                onPressed: onDownloadPressed,
                icon: const Icon(Icons.lock_outline),
                label: l10n.historyExportPreviewAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
