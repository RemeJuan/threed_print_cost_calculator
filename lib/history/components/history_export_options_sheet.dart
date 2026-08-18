import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

class HistoryExportOptionsSheet extends StatelessWidget {
  const HistoryExportOptionsSheet({super.key, required this.onExportSelected});

  final Future<void> Function(ExportRange range) onExportSelected;

  static const allRangeKey = ValueKey('history.export.range.all');
  static const last7DaysRangeKey = ValueKey('history.export.range.last7Days');
  static const last30DaysRangeKey = ValueKey('history.export.range.last30Days');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(kAppSpace16),
            child: Text(
              l10n.historyExportMenuTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            key: allRangeKey,
            title: Text(l10n.historyExportRangeAll),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.all);
            },
          ),
          ListTile(
            key: last7DaysRangeKey,
            title: Text(l10n.historyExportRangeLast7Days),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.last7Days);
            },
          ),
          ListTile(
            key: last30DaysRangeKey,
            title: Text(l10n.historyExportRangeLast30Days),
            onTap: () async {
              Navigator.pop(context);
              await onExportSelected(ExportRange.last30Days);
            },
          ),
          const SizedBox(height: kAppSpace8),
        ],
      ),
    );
  }
}
