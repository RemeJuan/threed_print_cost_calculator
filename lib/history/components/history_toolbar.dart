import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_search_bar.dart';

class HistoryToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onExportPressed;

  const HistoryToolbar({
    super.key,
    required this.controller,
    required this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: kAppSearchSectionPadding,
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              controller: controller,
              hintText: l10n.historySearchHint,
              showClearButton: true,
              onChanged: (_) {},
              textFieldKey: const ValueKey<String>('history.search.input'),
              clearButtonKey:
                  const ValueKey<String>('history.search.clear.button'),
            ),
          ),
          const SizedBox(width: kAppSpace8),
          IconButton(
            key: const ValueKey<String>('history.export.button'),
            icon: const Icon(Icons.upload_file),
            tooltip: l10n.exportButton,
            onPressed: onExportPressed,
          ),
        ],
      ),
    );
  }
}
