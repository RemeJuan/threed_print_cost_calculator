import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';

class BatchCostingPageHeaderActions extends StatelessWidget {
  const BatchCostingPageHeaderActions({
    super.key,
    required this.hasItems,
    required this.isPremium,
    required this.batchImportAllowed,
    required this.addManualLabel,
    required this.importLabel,
    required this.onAddManual,
    required this.onImport,
  });

  final bool hasItems;
  final bool isPremium;
  final bool batchImportAllowed;
  final String addManualLabel;
  final String importLabel;
  final VoidCallback onAddManual;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    if (!hasItems) return const SizedBox.shrink();

    return Align(
      alignment: AlignmentDirectional.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTertiaryButton(
            onPressed: onAddManual,
            label: addManualLabel,
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: kAppSpace8),
          if (isPremium)
            Opacity(
              opacity: batchImportAllowed ? 1 : 0.55,
              child: AppTertiaryButton(
                onPressed: onImport,
                label: importLabel,
                icon: const Icon(Icons.upload_file),
              ),
            ),
        ],
      ),
    );
  }
}
