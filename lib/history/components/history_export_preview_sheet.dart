import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

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
              ).textTheme.labelLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(8, 8, 18, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                csvPreview,
                key: const ValueKey<String>('history.export.preview.csv'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const ValueKey<String>(
                  'history.export.preview.download.button',
                ),
                onPressed: onDownloadPressed,
                icon: const Icon(Icons.lock_outline),
                label: Text(l10n.historyExportPreviewAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
