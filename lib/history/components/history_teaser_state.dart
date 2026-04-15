import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

class HistoryTeaserState extends StatelessWidget {
  const HistoryTeaserState({
    super.key,
    required this.onUpgradePressed,
    required this.onExportPreviewPressed,
  });

  final VoidCallback onUpgradePressed;
  final VoidCallback onExportPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              key: const ValueKey<String>('history.teaser.state'),
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 56, color: Colors.white70),
                const SizedBox(height: 16),
                Text(
                  l10n.historyTeaserTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.historyTeaserDescription,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    key: const ValueKey<String>('history.export.preview.entry'),
                    leading: const Icon(Icons.upload_file_outlined),
                    title: Text(l10n.historyExportPreviewEntry),
                    trailing: Text(
                      l10n.historyExportPreviewSampleLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: Colors.white54),
                    ),
                    onTap: onExportPreviewPressed,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const ValueKey<String>('history.teaser.cta'),
                    onPressed: onUpgradePressed,
                    child: Text(l10n.historyTeaserCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
