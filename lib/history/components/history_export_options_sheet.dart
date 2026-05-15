import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

class HistoryExportOptionsSheet extends StatelessWidget {
  const HistoryExportOptionsSheet({super.key, required this.onExportSelected});

  final Future<void> Function(ExportRange range) onExportSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.historyExportMenuTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            title: Text(l10n.historyExportRangeAll),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.all);
            },
          ),
          ListTile(
            title: Text(l10n.historyExportRangeLast7Days),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.last7Days);
            },
          ),
          ListTile(
            title: Text(l10n.historyExportRangeLast30Days),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.last30Days);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
